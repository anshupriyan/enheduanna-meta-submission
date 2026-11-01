# 𒀭 ENHEDUANNA — Master Codebase Memory & Technical Context

> **File:** `C:\meta hackathon\CODEBASE_MEMORY.md`  
> **Created:** November 2, 2026  
> **Purpose:** Authoritative, persistent technical context and system architecture map for the Enheduanna desktop intelligence ecosystem. Read this document upon entering any new session or working in a fresh cloned directory to instantly achieve full operational context.

---

## 1. Project Overview & Hackathon Positioning

- **Project Name:** Enheduanna (named after the Sumerian high priestess of Ur, c. 2300 BCE, the first named author in human history who pressed stylus to wet clay to turn fleeting human thought into permanent memory).
- **Core Thesis:** *"Ask about anything you saw on your computer, then act on it."*
- **Event:** Meta Global AI Hackathon 2026.
- **Model Stack:** Meta Model API (`https://api.meta.ai/v1`):
  - **Tool Dispatch Model:** `muse-spark-1.3` (fast, concurrent tool selection and execution).
  - **Synthesis & Conclusion Model:** `muse-wonder-1.0` (deep reasoning, multimodal vision, cohesive final write-ups).
- **Architecture Model:** Model Context Protocol (MCP 2.0) over standard I/O (JSON-RPC stdio multiplexing).

---

## 2. Directory Map & Repository Topology

The workspace at `C:\meta hackathon\` is structured as a dual-repository development and submission ecosystem:

```
C:\meta hackathon\
├── CODEBASE_MEMORY.md                       <-- This file (master context reference)
├── SUBMISSION_ARCHITECTURE_AND_SYNC_GUIDE.md <-- Historical Cerebral Valley prior-work ruling doc
├── HACKATHON_STATUS_AUDIT.md                <-- Mid-hackathon readiness audit
├── NEXT_SESSION_PLAN.md                     <-- Historical sprint milestones
│
├── enheduanna-submission/                   <-- OFFICIAL HACKATHON SUBMISSION REPO (Public)
│   ├── Git Remote: origin -> https://github.com/anshupriyan/enheduanna-meta-submission.git (branch: main)
│   ├── Git History: 100% post-kickoff commits (mathematically clean, zero pre-hackathon history)
│   ├── app/
│   │   ├── core/                           <-- Node/TS Integration Core (:4100)
│   │   │   ├── src/
│   │   │   │   ├── agent/orchestrator.ts   <-- ReAct dual-model loop, step limits, evidence packing
│   │   │   │   ├── mcp/manager.ts          <-- MCP multiplexer (memvision + cli-bridge stdio)
│   │   │   │   ├── mcp/buffer.ts           <-- LRU tool result cache (64KB/128KB buf_*)
│   │   │   │   ├── providers/meta.ts       <-- Meta API SSE client + reasoning extractor
│   │   │   │   ├── trace/bus.ts            <-- 100-event ring buffer with secret scrubbing
│   │   │   │   ├── config.ts               <-- Local-first path resolution (./memvison/data, etc.)
│   │   │   │   └── server.ts               <-- node:http zero-framework API server
│   │   │   ├── prompts/system_prompt.txt   <-- 13 core behavioral rules & few-shot prompts
│   │   │   └── dist/                       <-- Compiled JavaScript from `npm run build`
│   │   └── dashboard/                      <-- Glassmorphic Web UI (:4100/)
│   │       ├── index.html, styles.css
│   │       └── app.js                      <-- SSE client, thinking drawer, lightbox, filter guards
│   ├── memvison/                           <-- Python Continuous Memory Scribe
│   │   ├── src/memvision/
│   │   │   ├── storage.py                  <-- SQLite WAL + FTS5 + sessions_summary backfilling
│   │   │   ├── mcp_server.py               <-- 9 MCP tools over stdio
│   │   │   ├── capture.py                  <-- mss WinSta0 screen capture worker thread
│   │   │   ├── ocr.py                      <-- Native offline Windows WinRT OCR + Tesseract fallback
│   │   │   ├── privacy.py                  <-- 13 regex families, spatial blackout curtains
│   │   │   ├── change_detector.py          <-- Perceptual dhash gate (threshold 3)
│   │   │   └── web_server.py               <-- Local monitoring dashboard (:8765)
│   │   ├── data/                           <-- SQLite DB (memvision.db) and screenshots/
│   │   └── .venv/                          <-- Isolated Python 3.12 virtual environment
│   ├── igi/                                <-- Python + PySide6 "The Eye" Companion HUD
│   │   ├── bridge/core_client.py           <-- Core HTTP & SSE client, spatial grounding
│   │   ├── sam/router.py                   <-- Dual MoE SAM router (Sobel edge snap + WinRT OCR)
│   │   ├── hud/chat_window.py              <-- 440x600 floating companion window
│   │   └── overlay/canvas.py               <-- Ctrl+Shift+Q screen-freeze selector
│   ├── scripts/
│   │   ├── setup.ps1                       <-- Automated 1-click environment installer
│   │   ├── launch_igi.bat / launch_igi.ps1 <-- 1-click Eye companion launcher
│   │   └── verify_all_tests.ps1            <-- 55-test verification suite runner
│   ├── enheduanna.config.json              <-- Live local config (gitignored)
│   ├── enheduanna.config.example.json      <-- Tracked template with placeholder keys
│   └── setup.bat                           <-- Batch wrapper for setup.ps1
│
├── enheduanna/                              <-- ACTIVE DEVELOPMENT MONOREPO (Internal Dev)
│   ├── Same layout as submission, plus internal experiment branches and notes
│   └── Tracked on local git remote `local-dev`
│
├── memvison/                                <-- STANDALONE SCRIBE REPOSITORY (master)
│   └── Canonical authoring source for `storage.py` and visual perception engine
│
└── cli-bridge/                              <-- EXTERNAL OPERATOR TOOL (branch: meta-hackathon)
    ├── Disclosed pre-existing open-source dependency: https://github.com/anshupriyan/cli-bridge
    ├── Node/TypeScript MCP server for sandboxed OS operations
    ├── src/policy/                          <-- PolicyEngine (allow / ask / deny), JIT session grants
    └── build/index.js                       <-- Compiled executable spawned by Core via stdio
```

---

## 3. Tri-Faculty Architecture Over MCP 2.0

```
                   ┌──────────────────────────────────────────────┐
                   │         User (Browser :4100 / IGI HUD)       │
                   └──────────────────────┬───────────────────────┘
                                          │
                                          ▼
                   ┌──────────────────────────────────────────────┐
                   │        Enheduanna Integration Core           │
                   │      (app/core/src/server.ts :4100)          │
                   └───────┬──────────────────────────────┬───────┘
                           │                              │
         Dual-Model ReAct  │                              │ SSE TraceBus
         Orchestrator Loop │                              │ (Live System Trace)
                           ▼                              ▼
                 Meta Model API (REST)           Web Dashboard / HUD
          ┌───────────────────────────────┐
          │  Step 1..N: muse-spark-1.3    │ (Fast tool selection & dispatch)
          │  Final:     muse-wonder-1.0   │ (Deep synthesis, multimodal vision)
          └───────────────┬───────────────┘
                          │ MCP JSON-RPC stdio
            ┌─────────────┴─────────────┐
            ▼                           ▼
 ┌──────────────────────┐    ┌──────────────────────┐
 │ The Scribe (memvison)│    │The Operator(cli-bridge│
 ├──────────────────────┤    ├──────────────────────┤
 │ • Continuous capture │    │ • PolicyEngine       │
 │ • WinRT OCR offline  │    │ • Sandboxed Shell    │
 │ • Spatial Blackouts  │    │ • Dev Mode OFF gate  │
 │ • SQLite FTS5 Search │    │ • JIT Path Approvals │
 │ • 9 MCP Tools        │    │ • 13+ MCP Tools      │
 └──────────────────────┘    └──────────────────────┘
```

### Faculty 1: The Scribe (`memvison/`)
- **Continuous Loop:** Background worker captures active monitors every 2 seconds via `mss`.
- **Privacy Gate:** Before saving or running OCR, windows matching blocked apps (e.g. 1Password, Banking, Discord) or titles are masked with solid spatial blackout mattes. OCR text is scrubbed against 13 regex families (Bearer tokens, OpenAI/Meta/Anthropic keys, PEM private keys, URL secrets).
- **dHash Change Detection:** Compares perceptual 64-bit difference hash with threshold 3. Frames with text similarity $\ge 0.90$ during video playback are deduplicated.
- **SQLite Storage:** Tables: `captures`, `windows`, `episodes`, `sessions_summary`. Full-text indexed via SQLite FTS5 with auto-sync triggers.
- **Key MCP Tools:** `search_desktop_memory`, `get_recent_memory`, `get_session_summaries`, `get_capture_details`, `get_memory_statistics`, `get_window_crop`.

### Faculty 2: The Operator (`cli-bridge/`)
- **Prior Work Disclosure:** External open-source dependency (branch `meta-hackathon`).
- **Policy Engine:** Strict tri-state evaluation (`allow`, `ask`, `deny`). Sensitive tools (`execute_command`, out-of-bounds writes) trigger human approval cards in the UI.
- **Dev Mode:** Default is `OFF` (terminal execution blocked until user explicitly toggles it).
- **Path Hardening:** Canonicalizes paths using `resolveSafePath` with symlink traversal checks (CWE-59 defense).
- **Key MCP Tools:** `read_file`, `write_file`, `edit_file`, `list_directory`, `search_files`, `grep_content` (bundled ripgrep), `execute_command`, `request_path_access`.

### Faculty 3: The Eye (`igi/` 𒅆)
- **Circle-to-Search:** Activated via global hotkey `Ctrl+Shift+Q`. Freezes the desktop display.
- **Dual MoE SAM Router:** Sobel edge gradient algorithm snaps the circled boundary in $<15$ ms (100% offline, zero cloud reliance).
- **Spatial Grounding:** Crops the circled region, runs native WinRT OCR word-box grounding, and captures:
  - Active Window Name & Executable
  - Active Browser URL (via UI Automation)
  - Active File Explorer Directory Path
  - Full Window Surrounding Text
- **HUD Window:** Frameless Obsidian/Amber themed PySide6 window (`440x600`) communicating via SSE with Core.

---

## 4. Key Endpoints, Ports & Protocols

| Service | Port / Protocol | Purpose | Key Routes |
| :--- | :--- | :--- | :--- |
| **Integration Core** | `127.0.0.1:4100` (HTTP / SSE) | Main API & Web Dashboard | `/`, `/health`, `/tools`, `/api/chat` (SSE), `/api/trace` (SSE), `/api/capture/image/:id`, `/api/approvals` |
| **MemVision Monitor** | `127.0.0.1:8765` (HTTP) | Screen memory inspector | `/`, `/api/captures`, `/api/stats`, `/api/timeline` |
| **MCP MemVision** | `stdio` (JSON-RPC 2.0) | Scribe tool multiplexing | Direct stdio spawn by Core via Node child process |
| **MCP CLI Bridge** | `stdio` (JSON-RPC 2.0) | Operator tool multiplexing| Direct stdio spawn by Core via Node child process |

---

## 5. Critical Edge Cases & Bugs Resolved

When debugging or maintaining this codebase, be aware of these critical edge cases that have already been diagnosed and fixed:

### 1. `get_session_summaries` Timeout Fix (`storage.py`)
- **Problem:** `mcp_server.py` exposed `get_session_summaries`, but `storage.py` was missing the implementation in `enheduanna-submission`, raising Python `AttributeError` and causing `MCP error -32001: Request timed out`.
- **Fix:** Restored the 224 lines in [`memvision/storage.py`](file:///C:/meta%20hackathon/enheduanna-submission/memvison/src/memvision/storage.py) defining `sessions_summary` table schema, `save_session_summary(...)`, `get_session_summaries(...)`, and `backfill_session_summaries(hours=48)`. Verified with $<1$s execution time.

### 2. Synthetic Prompts Rendering as Fake User Chat Bubbles
- **Problem:** In two-model routing, after Muse Spark executed tools, the packed evidence was sent to Muse Wonder as a message with `role: "user"`. In the dashboard, `app.js` rendered *any* message with `role: "user"` as a blue "YOU" bubble, showing raw JSON and tool tables.
- **Fix:** In [`app/dashboard/app.js`](file:///C:/meta%20hackathon/enheduanna-submission/app/dashboard/app.js) lines 702–708, synthetic messages starting with `[ACTION & TOOL EXECUTION RESULTS]`, `[ACTIONS COMPLETED]`, and `Instructions for Wonder Synthesis:` are filtered out and suppressed from the chat feed.

### 3. Step Cap Overrun & Graceful Final Conclusion
- **Problem:** When an agent hit `maxSteps` (e.g. 16 steps during deep codebase exploration), it previously cut off mid-thought, outputting only truncated fragments.
- **Fix:** In [`app/core/src/agent/orchestrator.ts`](file:///C:/meta%20hackathon/enheduanna-submission/app/core/src/agent/orchestrator.ts), hitting the step limit now emits `[NOTICE: STEP BUDGET REACHED - CONCLUDE THOUGHTS]`, suppresses further tool calls, and guarantees a final synthesis step with Muse Wonder (`maxSteps + 2`) to deliver a cohesive concluding response.

### 4. Portable Local Path Resolution
- **Problem:** Core previously pointed to hardcoded absolute paths (`C:\meta hackathon\memvison\data\memvision.db`).
- **Fix:** In `config.ts` and `manager.ts`, paths are resolved relative to the submission root directory (`./memvison/data/memvision.db` and `./memvison/.venv/Scripts/python.exe`), allowing the folder to run anywhere without path conflicts.

### 5. Windows PowerShell `$null` Comparison
- **Problem:** PSScriptAnalyzer warned that `$null` must be on the left side of equality operators in `setup.ps1`.
- **Fix:** Updated comparison in `setup.ps1` line 100 to `($null -ne $target)`.

### 6. `launch_igi.bat` Syntax & Deferred Variable Expansion
- **Problem:** `python -c "import PySide6\nprint(...)"` threw syntax errors in CMD, and `%ERRORLEVEL%` expanded to `0` inside parenthesized blocks.
- **Fix:** Replaced with clean one-liner `import PySide6` and used dynamic error level evaluation.

---

## 6. Fresh Machine / Evaluator Setup Guide

If an evaluator clones the repository into a completely fresh folder on another PC, follow these exact steps:

### Step 1: Clone Repository
```bash
git clone https://github.com/anshupriyan/enheduanna-meta-submission.git
cd enheduanna-meta-submission
```

### Step 2: Configure Environment Keys
Create `enheduanna.config.json` by copying `enheduanna.config.example.json`:
```bash
copy enheduanna.config.example.json enheduanna.config.json
```
Edit `enheduanna.config.json` and insert your Meta Model API key:
```json
"model": {
  "provider": "meta",
  "modelName": "muse-spark-1.3",
  "toolModel": "muse-spark-1.3",
  "synthesisModel": "muse-wonder-1.0",
  "baseUrl": "https://api.meta.ai/v1",
  "apiKey": "YOUR_META_API_KEY_HERE"
}
```

### Step 3: Run 1-Click Setup
In PowerShell (as administrator or standard user):
```powershell
.\setup.bat
# Or directly:
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```
*What this script does automatically:*
1. Clones external `cli-bridge` (branch `meta-hackathon`) into `..\cli-bridge` if not present.
2. Creates Python virtual environment at `memvison\.venv` using Python 3.12.
3. Installs `memvison/requirements.txt` and optionally PySide6 for `igi`.
4. Installs Node.js dependencies and runs TypeScript `npm run build` in both `cli-bridge` and `app/core`.

### Step 4: Launch Services
1. **Start Core Service & Dashboard:**
   ```bash
   cd app/core
   npm start
   ```
   Open [http://127.0.0.1:4100/](http://127.0.0.1:4100/) in your browser.

2. **Launch The Eye Companion HUD (Optional):**
   ```bash
   .\scripts\launch_igi.bat
   ```
   Press `Ctrl+Shift+Q` anywhere on your desktop to circle and inspect any screen region.

---

## 7. Test Suites & Verification

To verify full system integrity, run the automated test suite:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify_all_tests.ps1
```
- **Python Tests:** 35 unit & integration tests in `memvison/tests/` (OCR, dhash change detection, spatial privacy blackouts, FTS5 sync, session clustering).
- **Node.js Tests:** 20 acceptance and orchestrator tests in `app/core/test/` (ReAct loop, secret scrubber, buffer truncation, multi-step flow).

---

## 8. Summary of Active Working State

- **Current Submission Branch:** `main` (clean, fully synced, tracked by `origin`).
- **Latest Remote Commit:** `6fe99fd` (`feat(memvision,docs): sync get_session_summaries to storage.py and add submission architecture sync guide`).
- **Live Server Port:** `http://127.0.0.1:4100` (PID running in background outside sandbox).
- **All Core Features Operational:** Scribe capture, Operator shell execution with human-in-the-loop approvals, Eye HUD spatial snapping, and dual-model ReAct orchestration.
