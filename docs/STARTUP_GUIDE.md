# 𒀭 ENHEDUANNA — Complete Quickstart & System Startup Guide

> **File:** `STARTUP_GUIDE.md`  
> **Applicable To:** `C:\meta hackathon\enheduanna-submission` (or any fresh clone from GitHub).  
> **Target Audience:** Users, judges, and developers starting the Enheduanna ecosystem from scratch.

---

## 📋 System Components Overview

When fully operational, Enheduanna consists of three lightweight local services:

| Component | Technology | Default Port / Interface | Role |
| :--- | :--- | :--- | :--- |
| **1. Enheduanna Core & Dashboard** | Node.js / TypeScript | `http://127.0.0.1:4100` | ReAct dual-model orchestrator, MCP multiplexer, live SSE trace, and main glassmorphic chat interface. |
| **2. MemVision Memory Dashboard** | Python Standard Library | `http://127.0.0.1:8765` | Visual screenshot gallery, capture timeline, privacy filters, and FTS5 memory search viewer. |
| **3. IGI (The Eye) Companion** | Python + PySide6 | Floating HUD + `Ctrl+Shift+Q` | Circle-to-Search gesture snapper, native WinRT OCR word-box grounding, and live multimodal inspector. |

---

## 🛠️ Step 0: Initial 1-Click Setup (Run Once)

Before starting the services for the first time on any PC:

### 1. Configure Your API Key
Copy the example config and add your Meta Model API key:
```cmd
copy enheduanna.config.example.json enheduanna.config.json
```
Open `enheduanna.config.json` and verify the `apiKey` field:
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

### 2. Run the Automated Setup
In the repository root, run the setup script:
```cmd
setup.bat
```
*(Or in PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1`)*

**What this automatically handles:**
- Clones and links the external `cli-bridge` dependency (branch: `meta-hackathon`).
- Sets up an isolated Python 3.12 virtual environment at `memvison\.venv`.
- Installs all Python OCR, capture, and MCP packages.
- Prompts to install `PySide6` for the optional IGI companion window.
- Installs Node modules and compiles TypeScript (`npm run build`) in both `cli-bridge` and `app/core`.

---

## 🚀 Step 1: Start Enheduanna Core & Chat Dashboard (Port 4100)

This is the primary brain of the system. It connects to the Meta API and automatically spawns the background MCP servers (`memvision` and `cli-bridge`).

### Command:
Open a terminal in the project root:
```powershell
cd app\core
npm start
```

### Output:
```
  𒀭 Enheduanna Integration Core Service
  • Host: http://127.0.0.1:4100
  • Model: muse-spark-1.3 (meta)
  • Auth: API Key configured for META
------------------------------------------------------------------
[INFO] SQLite database initialized at memvison\data\memvision.db
[INFO] mem-vision-mcp MCP Server started listening on stdio.
[cli-bridge] Workspace root set to: C:\...\enheduanna-submission
[cli-bridge] Policy mode ACTIVE with 2 root(s).
[cli-bridge] Server connected and listening on stdin/stdout
  🚀 Enheduanna Server is LIVE at http://127.0.0.1:4100
  • Dashboard: http://127.0.0.1:4100/
```

### Accessing the Dashboard:
Open your browser and navigate to:
👉 **[http://127.0.0.1:4100/](http://127.0.0.1:4100/)**

**Features available:**
- Chat with your desktop screen memory ("What was I doing 10 minutes ago?", "Find that video I was watching").
- Run sandboxed workspace tasks with real-time approval cards.
- View live SSE system traces in the right-hand inspection drawer.
- Toggle continuous background memory recording with the **Recording** indicator in the top navbar.

---

## 🖼️ Step 2: Start MemVision Memory Dashboard (Port 8765)

The Scribe provides a zero-dependency dedicated monitor for viewing captured screenshots, inspecting OCR extractions, and reviewing privacy redactions.

### Command:
Open a second terminal in the project root:
```powershell
cd memvison
.\.venv\Scripts\python.exe main.py ui
```

### Output:
```
[INFO] MemVision Web Dashboard running at http://127.0.0.1:8765/
[INFO] Serving captures from memvison/data/memvision.db
```

### Accessing the Monitor:
Open your browser and navigate to:
👉 **[http://127.0.0.1:8765/](http://127.0.0.1:8765/)**

**Features available:**
- **Capture Timeline:** Visual grid of screen captures ordered chronologically.
- **OCR Inspector:** Click any thumbnail to see the exact text extracted via Windows WinRT OCR.
- **Privacy Verification:** Visually confirm that passwords, API keys, and private windows are masked with solid blackout curtains.
- **Database Statistics:** Total capture count, deduplicated frames, and disk space usage.

---

## 👁️ Step 3: Start IGI (The Eye) Visual Companion HUD

IGI provides on-screen spatial perception, Circle-to-Search, and an Obsidian & Amber floating companion window.

### Command:
Open a third terminal (or double-click the batch file in Windows Explorer):
```cmd
.\scripts\launch_igi.bat
```
*(Or in PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\launch_igi.ps1`)*

### Output:
```
==========================================================
   ::: LAUNCHING IGI (THE EYE OF ENHEDUANNA) :::
   Interpreter: ...\memvison\.venv\Scripts\python.exe
==========================================================
[IGI] Global hotkey registered: Ctrl+Shift+Q
[IGI] Connected to Enheduanna Core at http://127.0.0.1:4100
[IGI] Companion HUD window active.
```

### Using IGI:
1. **Circle-to-Search (`Ctrl+Shift+Q`):**
   - Press **`Ctrl+Shift+Q`** anywhere on your desktop.
   - The screen freezes with a darkened overlay.
   - Use your mouse to draw a circle around any code snippet, image, error box, or UI component.
   - IGI's Sobel gradient algorithm snaps to the exact bounding box in $<15$ ms and runs native WinRT OCR word-box grounding.
2. **The Floating Companion HUD:**
   - A sleek `440x600` dark window appears on your screen.
   - It automatically attaches the active window title, URL, file path, and circled visual crop.
   - Type any question or click quick-action pills (**Explain**, **Refactor**, **Summarize**, **Debug**).
   - The companion streams the answer live directly from Enheduanna Core.

---

## 🔄 Quick Multi-Window Terminal Reference

To run the complete system during testing or evaluation, keep these three lightweight terminal tabs open:

```
Tab 1 (Core & Chat):     cd app\core; npm start
Tab 2 (MemVision View):   cd memvison; .\.venv\Scripts\python.exe main.py ui
Tab 3 (The Eye HUD):      .\scripts\launch_igi.bat
```

---

## ❓ Troubleshooting & FAQs

### Q1: IGI shows `⚠️ Localhost Core Offline`
- **Cause:** Enheduanna Core (`app/core`) is not running on port 4100.
- **Fix:** In Tab 1, run `cd app\core; npm start`. Once port 4100 is listening, IGI will immediately turn green and report `Connected`.

### Q2: Port 4100 is already in use (`EADDRINUSE`)
- **Cause:** A previous Node process is still holding the port.
- **Fix:** In PowerShell, find and stop the process:
  ```powershell
  Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
  ```

### Q3: PySide6 is missing when launching IGI
- **Cause:** PySide6 installation was skipped during initial setup.
- **Fix:** Run the following command inside your virtual environment:
  ```powershell
  .\memvison\.venv\Scripts\python.exe -m pip install PySide6-Essentials
  ```

### Q4: Historical memory query returns "No activity recorded"
- **Cause:** In a brand-new clone, `memvision.db` is empty until you start recording.
- **Fix:** In the main dashboard (`http://127.0.0.1:4100`), ensure the **Recording** badge is green (or run `.\memvison\.venv\Scripts\python.exe main.py run` in a terminal) and browse for 1-2 minutes. Enheduanna will automatically cluster your activity into episodic memory.
