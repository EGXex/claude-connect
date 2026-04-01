# CONNECT — Claude-to-Claude Autonomous Bridge

## ⚠️ Warnings

- **Token usage:** Auto mode runs indefinitely. Each turn consumes Claude Pro tokens. Stop it with Ctrl+C when done or you will burn through your limits.
- **Rate limits:** Claude Pro has usage limits. Long sessions may get throttled or blocked mid-conversation.
- **Do not touch your PC while running:** The watcher controls your keyboard and mouse focus. Clicking elsewhere will send keystrokes to the wrong window and break the session.
- **Conversations are sent to Anthropic:** All messages go through Claude's servers. Do not use sensitive or private topics.
- **Conversation is logged:** Every turn is saved to `conversation.txt` in the CONNECT folder automatically.

--- 

## 1. Folder Location

Place the entire `CONNECT` folder somewhere inside your npm global directory. The default expected path is:

```
"YOUR MAIN DISK":\npm-global\CONNECT\
```

If your npm global prefix is different, put it wherever `npm config get prefix` points. You can find yours by running:

```
npm config get prefix
```

Then place the folder there so the structure looks like:

```
<your-npm-prefix>\CONNECT\
├── setup.bat
├── start.bat
├── watcher.js
├── package.json
├── RULES.md
├── SESSION_A.md
├── SESSION_B.md
├── SESSION_PROMPT.md
├── msg_a.txt
├── msg_b.txt
├── response_a.txt
├── response_b.txt
└── conversation.txt
```

`setup.bat` will detect the folder's location and patch all file paths in the session files automatically — you don't need to edit them by hand.

---

## 2. Setup

Run once before anything else:

```
setup.bat
```

This installs Node.js (if missing), installs dependencies, and patches file paths automatically.

---

## 3. How to Use

### Auto mode (recommended)

1. Open two terminal windows
2. Rename them (see section 4 below)
3. Paste `SESSION_A.md` content into terminal 1
4. Paste `SESSION_B.md` content into terminal 2
5. Run `start.bat`, enter a topic when prompted
6. Sessions will talk to each other automatically

### Manual mode (one turn at a time)

1. Open two terminal windows
2. Paste `SESSION_A.md` into terminal 1, `SESSION_B.md` into terminal 2
3. Write your opening message into `msg_a.txt` (any text editor)
4. In terminal 1: type `go` and press Enter
5. Copy contents of `response_a.txt` into `msg_b.txt`
6. In terminal 2: type `go` and press Enter
7. Repeat

---

## 4. How to Rename a Terminal Window

Auto mode requires two **separate** terminal windows (not tabs in the same window), titled exactly `SessionA` and `SessionB`.

Open each as its own window, then right-click the tab → **Rename** → type `SessionA` (or `SessionB`).

Do this **before** running `start.bat`.

> **Note:** Only tested on Windows 11.

---

## 5. If Something Breaks

Send these files to Claude and describe what went wrong:

| Problem | Files to share |
|---------|---------------|
| Watcher not triggering sessions | `watcher.js`, `start.bat` |
| Sessions not reading/writing files | `SESSION_A.md`, `SESSION_B.md`, `RULES.md` |
| Setup failing | `setup.bat`, `package.json` |
| Wrong behavior / off-topic replies | `RULES.md`, `SESSION_PROMPT.md` |
| Everything broken | All `.md` files + `watcher.js` + `start.bat` + `setup.bat` |

---

## 6. What Is This

CONNECT makes two Claude Code sessions talk to each other without you typing anything.

Each session runs in its own terminal window. They communicate through plain text files:

- Session A reads `msg_a.txt`, writes its reply to `response_a.txt`
- `watcher.js` detects the new reply, copies it to `msg_b.txt`, and triggers Session B
- Session B reads `msg_b.txt`, writes to `response_b.txt`
- Watcher copies that back to `msg_a.txt` and triggers Session A again
- Loops until you stop it

The watcher uses PowerShell to focus the correct terminal window and robotjs to type `go` into it automatically.


MY NOTE, i checked around a lot about what skills or what apps could be used to connect 2 claudes, could find only for "API - Pay Per Usage" wanted to make one that is mine AND works in PRO account
i dont know any programming or coding at all so this was vibe coded.
SORRY FOR BRUTEFORCING the manual method. i have no idea about what other methods are there :/
