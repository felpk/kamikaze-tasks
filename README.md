# kamikaze-tasks

[Português](README.pt-BR.md) · [Français](README.fr.md)

One task, one contract, one run, then the pane dies.

**Problem.** You give an agent a one-shot task. It does more than you asked, or less, and then says "done" without proving it. The tmux pane stays open, and the side ideas it had get lost.

**Solution.** `kt` wraps the `claude` CLI in a fixed loop:

1. **Contract.** Claude reads the repo (plan mode, read-only) and writes the goal, 1 to 5 checks that a command can verify, what it will *not* do, its assumptions and the risk. It asks at most 3 questions, and only when a wrong guess would cost the run.
2. **Confirm.** You press Enter, type a correction, or quit. `--yes` skips this when the risk is low. High risk always asks.
3. **Run.** No questions and no waiting. Destructive commands (`rm -rf`, `push --force`, `reset --hard`, `docker volume rm`, `terraform destroy`…) are denied by the harness. If the task needs one, the run stops `BLOCKED` and gives you the exact command to run yourself.
4. **Verify.** Every check is run and quoted. A `DONE` with a failed check becomes `FAILED`.
5. **Die.** Side findings go to an inbox, and the tmux pane closes.

```
GOAL       Create hello.txt containing the word hello
DONE WHEN
  ✓ `test -f hello.txt` exits 0
  ✓ `cat hello.txt` prints exactly `hello`
NOT DOING
  ✗ Committing or pushing
RISK       low

DONE  I created hello.txt in the repo root. It isn't committed, as the contract asked.
  ✓ `test -f hello.txt` exits 0
      exit=0
  ✓ `cat hello.txt` prints exactly `hello`
      output: hello
pane closes in 5s · any key keeps it
```

## Install

Needs bash, `jq`, tmux (optional) and the [Claude Code](https://claude.com/claude-code) CLI.

```sh
git clone https://github.com/felpk/kamikaze-tasks && cd kamikaze-tasks && ./install.sh
```

Optional tmux key binding (prefix + K opens a kamikaze pane):

```tmux
bind K split-window -c '#{pane_current_path}' kt
```

Inside Claude Code, the same loop is a skill:

```
/plugin marketplace add felpk/kamikaze-tasks
/plugin install kamikaze-tasks@kamikaze-tasks
```

## Use

```
kt "task"                 contract -> confirm -> run -> verify -> pane closes
kt                        ask for the task first (for a key binding)
kt new "task"             same, in a new tmux pane
kt resume <id> [answer]   continue a BLOCKED run
kt inbox [take N|clear]   side findings parked by runs
kt log [id]               past runs
kt park "text"            add a line to the inbox
```

Flags: `-y/--yes` skips confirmation when risk is low, `-k/--keep` keeps the pane open.
Env: `KT_DENY` (comma list, replaces the deny list), `KT_PERMISSION_MODE` (default: your settings, else `acceptEdits`), `KT_MODEL`, `KT_HOME` (default `~/.kamikaze`), `KT_COUNTDOWN`.

Runs live in `~/.kamikaze/runs/<id>/` (task, contract, report, status). Nothing leaves your machine except your normal `claude` calls.

## Tests

```sh
test/run.sh   # flow tests with a fake claude: no network, no tokens
```

## See also

- [beautify-tmux](https://github.com/felpk/beautify-tmux): colours each pane border by the agent's state.
- [claude-visual-check-no-images](https://github.com/felpk/claude-visual-check-no-images): checks web pages as text instead of screenshots.

MIT
