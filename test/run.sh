#!/usr/bin/env bash
# Flow tests for kt with a fake claude. No network, no tokens.
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd); kt="$here/../bin/kt"
pass=0 fail=0
ok()  { pass=$((pass+1)); echo "ok   $1"; }
bad() { fail=$((fail+1)); echo "FAIL $1"; }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

setup() {
  T=$(mktemp -d); export FAKE_DIR="$T/fake" KT_HOME="$T/home" KT_CLAUDE="$here/fake-claude" HOME="$T"
  export KT_PERMISSION_MODE=acceptEdits; unset TMUX TMUX_PANE
  mkdir -p "$FAKE_DIR"
  echo '{"goal":"g","done_when":["file x exists"],"out_of_scope":["commit"],"assumptions":["a1"],"questions":[],"risk":"low"}' > "$FAKE_DIR/contract.json"
  echo '{"status":"DONE","summary":"made x","checks":[{"criterion":"file x exists","passed":true,"evidence":"ls x"}],"assumptions_made":[],"parked":["fix typo in README"]}' > "$FAKE_DIR/report.json"
}
run() { (cd "$T" && "$kt" "$@" < /dev/null > "$T/out" 2>&1); echo $? > "$T/rc"; }
last() { ls -1 "$KT_HOME/runs" | tail -1; }

setup; run -y "make x"
check "low risk + --yes runs without a terminal" '[ "$(cat $T/rc)" = 0 ] && grep -q DONE "$T/out"'
check "status saved" '[ "$(cat $KT_HOME/runs/$(last)/status)" = DONE ]'
check "parked item goes to the inbox" 'grep -q "fix typo in README" "$KT_HOME/inbox.md"'
check "run uses the chosen permission mode" 'grep -q "mode=acceptEdits" "$FAKE_DIR/stdin.log"'
check "destructive commands denied in the run" 'grep -q "mode=acceptEdits.*disallowedTools.*Bash(rm -rf:\*)" "$FAKE_DIR/stdin.log"'
check "contract reaches the run" 'grep -q "file x exists" "$FAKE_DIR/stdin.log"'

setup; run "make x"
check "no --yes and no terminal: refuses to run" '[ "$(cat $T/rc)" != 0 ] && grep -q "confirmation needed" "$T/out" && [ ! -f "$FAKE_DIR/report.n" ]'

setup; jq '.risk="high"' "$FAKE_DIR/contract.json" > "$T/c" && mv "$T/c" "$FAKE_DIR/contract.json"; run -y "deploy"
check "high risk ignores --yes" '[ "$(cat $T/rc)" != 0 ] && [ ! -f "$FAKE_DIR/report.n" ]'

setup; jq '.questions=["which db?"]' "$FAKE_DIR/contract.json" > "$T/c" && mv "$T/c" "$FAKE_DIR/contract.json"; run -y "migrate"
check "open questions without a terminal: refuses" '[ "$(cat $T/rc)" != 0 ] && grep -q "which db" "$T/out"'

setup; jq '.checks[0].passed=false' "$FAKE_DIR/report.json" > "$T/r" && mv "$T/r" "$FAKE_DIR/report.json"; run -y "make x"
check "DONE with a failed check becomes FAILED" '[ "$(cat $KT_HOME/runs/$(last)/status)" = FAILED ]'
check "FAILED run is parked with resume hint" 'grep -q "FAILED: .*kt resume" "$KT_HOME/inbox.md"'

setup; echo '{"status":"BLOCKED","summary":"no creds","checks":[],"assumptions_made":[],"parked":[],"question":"which token?"}' > "$FAKE_DIR/report.1.json"; run -y "push"
id=$(last)
check "BLOCKED is parked with its question" 'grep -q "BLOCKED: which token?" "$KT_HOME/inbox.md"'
run resume "$id" "use the CI one"
check "resume continues the run to DONE" '[ "$(cat $KT_HOME/runs/$id/status)" = DONE ] && grep -q "use the CI one" "$FAKE_DIR/stdin.log"'

setup; KT_DENY="Bash(foo:*)" run -y "make x"
check "KT_DENY replaces the deny list" 'grep -q "Bash(foo:\*)" "$FAKE_DIR/stdin.log" && ! grep -q "Bash(rm -rf" "$FAKE_DIR/stdin.log"'

setup; run park "look at logs"; run inbox
check "kt park + kt inbox" 'grep -q "look at logs" "$T/out"'
run log
check "kt log lists nothing breaks on empty" '[ "$(cat $T/rc)" = 0 ]'

echo "$pass passed, $fail failed"; [ $fail = 0 ]
