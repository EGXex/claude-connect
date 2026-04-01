// CONNECT/watcher.js — Claude session bridge
// Usage: node watcher.js
// Kill: Ctrl+C

const fs = require('fs');
const { execSync } = require('child_process');
const robot = require('robotjs');

const DIR = __dirname + '\\';
const RESP_A = DIR + 'response_a.txt';
const RESP_B = DIR + 'response_b.txt';
const MSG_A  = DIR + 'msg_a.txt';
const MSG_B  = DIR + 'msg_b.txt';
const LOG    = DIR + 'conversation.txt';

const CHECK_MS = 2000;

const WIN_A = 'SessionA';
const WIN_B = 'SessionB';

let lastSizeA = 0;
let lastSizeB = 0;
let turnCount = 0;
const IDLE_TIMEOUT_MS = 60000; // 60 seconds
let lastActivityTime = Date.now();

function checkIdle() {
  if (Date.now() - lastActivityTime > IDLE_TIMEOUT_MS) {
    console.log(`[WARN] No response from either session for ${IDLE_TIMEOUT_MS/1000}s. Sessions may be stuck.`);
    lastActivityTime = Date.now(); // reset to avoid spamming
  }
}

setInterval(checkIdle, IDLE_TIMEOUT_MS);

function focusWindow(title) {
  try {
    execSync(`powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).AppActivate('${title}')"`, { stdio: 'ignore' });
    return true;
  } catch { return false; }
}

function fileSize(f) {
  try { return fs.statSync(f).size; } catch { return 0; }
}

function readFile(f) {
  try { return fs.readFileSync(f, 'utf8').trim(); } catch { return ''; }
}

function writeFile(f, content) {
  fs.writeFileSync(f, content, 'utf8');
}

function triggerSession(winTitle, msgFile) {
  if (!focusWindow(winTitle)) {
    console.log(`[WARN] Window not found: "${winTitle}"`);
    return;
  }
  setTimeout(() => {
    robot.setKeyboardDelay(50);
    robot.typeString('go');
    setTimeout(() => {
      focusWindow(winTitle);
      setTimeout(() => {
        execSync(`powershell -NoProfile -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('{ENTER}')"`, { stdio: 'ignore' });
        console.log(`[→] Triggered: ${winTitle}`);
      }, 400);
    }, 300);
  }, 500);
}

function logTurn(speaker, content) {
  const timestamp = new Date().toLocaleTimeString();
  fs.appendFileSync(LOG, `[${timestamp}] ${speaker}:\n${content}\n\n`, 'utf8');
}

console.log('CONNECT watcher running. Ctrl+C to stop.\n');

setInterval(() => {
  // Session A responded
  const sizeA = fileSize(RESP_A);
  if (sizeA > lastSizeA && sizeA > 0) {
    lastSizeA = sizeA;
    const content = readFile(RESP_A);
    if (content) {
      turnCount++;
      lastActivityTime = Date.now();
      console.log(`[Turn ${turnCount}] A→B: ${content.slice(0, 80)}...`);
      logTurn('Session A', content);
      writeFile(MSG_B, content);
      writeFile(RESP_A, '');
      lastSizeA = 0;
      setTimeout(() => triggerSession(WIN_B, MSG_B), 300);
    }
  }

  // Session B responded
  const sizeB = fileSize(RESP_B);
  if (sizeB > lastSizeB && sizeB > 0) {
    lastSizeB = sizeB;
    const content = readFile(RESP_B);
    if (content) {
      turnCount++;
      lastActivityTime = Date.now();
      console.log(`[Turn ${turnCount}] B→A: ${content.slice(0, 80)}...`);
      logTurn('Session B', content);
      writeFile(MSG_A, content);
      writeFile(RESP_B, '');
      lastSizeB = 0;
      setTimeout(() => triggerSession(WIN_A, MSG_A), 300);
    }
  }
}, CHECK_MS);
