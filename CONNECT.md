# CONNECT — Claude-to-Claude Autonomous Bridge

## What This Does
Two Claude Code sessions talk to each other autonomously without user input.
A Node.js watcher (`watcher.js`) detects when one session writes a response, forwards it to the other session's input file, then uses robotjs + PowerShell to focus that window and type a trigger command into it.

## Architecture

```
User writes topic → msg_a.txt
        ↓
watcher.js detects msg_a.txt
        ↓
Focuses SessionA window → types "go" + Enter
        ↓
Session A reads msg_a.txt → replies → writes to response_a.txt
        ↓
watcher.js detects response_a.txt
        ↓
Copies content → msg_b.txt → focuses SessionB → types "go" + Enter
        ↓
Session B reads msg_b.txt → replies → writes to response_b.txt
        ↓
watcher.js detects response_b.txt → loops back to Session A
        ↓
(repeat forever until Ctrl+C)
```

## Files

| File | Purpose |
|------|---------|
| `watcher.js` | Main bridge script — watches files, triggers sessions |
| `start.bat` | Entry point — clears files, asks topic, launches watcher |
| `setup.bat` | One-time setup — installs deps and patches paths |
| `RULES.md` | Behavior rules pasted into each Claude session at start |
| `SESSION_A.md` | Prompt to paste into Session A terminal |
| `SESSION_B.md` | Prompt to paste into Session B terminal |
| `SESSION_PROMPT.md` | Both prompts in one place for reference |
| `msg_a.txt` | Input queue for Session A |
| `msg_b.txt` | Input queue for Session B |
| `response_a.txt` | Session A writes its response here |
| `response_b.txt` | Session B writes its response here |
| `package.json` | Node deps (robotjs) |
| `conversation.txt` | Auto-generated log of the full conversation |

## Dependencies
- Node.js v20+
- `robotjs` — native addon, installed via `setup.bat`
- PowerShell — built into Windows, used for window focus via `WScript.Shell.AppActivate`

## Window Titles
watcher.js expects terminals titled exactly:
```
SessionA
SessionB
```
Open each as its own **separate window** (not tabs in the same window), then right-click the tab → **Rename** → type `SessionA` (or `SessionB`).

If titles change, update `WIN_A` / `WIN_B` in `watcher.js`.

> **Note:** Only tested on Windows 11.

## Session Prompts
Each Claude session needs to be primed once at the start. Paste `SESSION_A.md` into terminal A and `SESSION_B.md` into terminal B.
The key behavior: when Claude receives `go`, it must:
1. Read its assigned input file (`msg_a.txt` for A, `msg_b.txt` for B)
2. Reply per RULES.md (2-4 sentences, no fluff)
3. Write response to its assigned `response_x.txt` (overwrite)
4. Say nothing else

## How to Start
1. Run `setup.bat` once to install dependencies and patch paths
2. Open two Claude Code terminal windows
3. In each terminal, set the title: `title SessionA` / `title SessionB`
4. Paste Session A prompt into terminal A, Session B prompt into terminal B
5. Double-click `start.bat`, enter the topic when prompted
6. Done — sessions run autonomously

## Kill Switch
- Close the watcher window (titled "CONNECT Watcher") or press Ctrl+C in it
- Everything stops immediately — Claude sessions go idle

## Known Limitations
- Window focus is OS-level — if you click elsewhere while watcher is triggering, keystrokes may land in the wrong window. Don't use the computer during a session.
- If a Claude session is mid-response when triggered again, the trigger keystroke may interrupt it. Increase `CHECK_MS` in `watcher.js` (default: 2000ms) if this happens.
- robotjs cannot target a window by title — it types wherever focus is. PowerShell `AppActivate` does the focusing first. If AppActivate fails (window minimized or title mismatch), watcher logs a warning and skips that turn.
- Claude Code sessions must be logged in — the script only sends keystrokes to existing sessions, it does not handle authentication.

## Tuning
| Variable | File | Default | Effect |
|----------|------|---------|--------|
| `CHECK_MS` | `watcher.js` | `2000` | How often watcher polls files (ms) |
| Response length | `RULES.md` | 2-4 sentences | Claude reply length |
| `WIN_A` / `WIN_B` | `watcher.js` | `SessionA` / `SessionB` | Terminal window titles to target |

## If Something Breaks
1. **Watcher not triggering** — make sure terminal titles are exactly `SessionA` and `SessionB` (case-sensitive)
2. **Keystrokes going to wrong window** — increase delay in `triggerSession()` in `watcher.js`
3. **robotjs fails to load** — re-run `setup.bat`; ensure Python and Visual Studio Build Tools are installed
4. **Session not responding** — re-paste the session prompt, Claude may have lost context
5. **Response file not being written** — Claude ignored the write instruction; re-prime the session
