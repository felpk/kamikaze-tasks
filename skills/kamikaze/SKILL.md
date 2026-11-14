---
name: kamikaze
description: Run one task kamikaze-style inside the current Claude Code session: write a short contract (goal, done-when checks, out of scope, risk), get one confirmation, do it, verify every check with real evidence, report DONE/BLOCKED/FAILED, park side findings with `kt park`, then close the tmux pane with `kt die`. Use when the user says "kamikaze", "kt", or asks for a one-shot task that should end the pane when done.
---

# kamikaze

One task, one contract, one run, then the pane dies.

1. **Contract.** Read what you need (read-only), then show:
   - GOAL: one sentence, in the user's words.
   - DONE WHEN: 1 to 5 checks a command or file read can verify.
   - NOT DOING: what a helpful agent would be tempted to add (refactors, commits, pushes, deploys).
   - ASSUMING: choices you make where the task is silent.
   - RISK: high if it touches production, deletes data, pushes, deploys, sends messages or spends money; medium if it changes many files or shared config; else low.
   Ask at most 3 questions, only when a wrong guess wastes the run or causes harm.
2. **Confirm.** Wait for one reply: go, a correction (rewrite the contract), or quit.
3. **Run.** Do only the contract. Never ask again. Never delete data, force-push, rewrite history, drop databases, remove containers or deploy unless the contract names that exact action; if needed, stop BLOCKED with the exact command for the user.
4. **Verify.** Run every DONE WHEN check and quote the real output. DONE only if all passed.
5. **Report.** `DONE | BLOCKED | FAILED`, at most 3 lines of what changed, one line per check with evidence, and the question if BLOCKED.
6. **Park.** Each thing worth doing outside the scope: `kt park "<one actionable line>"`.
7. **Die.** If DONE, run `kt die` (closes the tmux pane in 2s). If BLOCKED or FAILED, park it with `kt park` and leave the pane open.
