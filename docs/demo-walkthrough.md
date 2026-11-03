# Demo Walkthrough & Scenario Audit

> **Meta Global AI Developer Hackathon 2026** — *Indie Developer Track: Build for Your World*  
> **Repository:** [`anshupriyan/enheduanna-meta-submission`](https://github.com/anshupriyan/enheduanna-meta-submission)  
> **Target System:** Enheduanna (MemVision + IGI + cli-bridge)

---

## 1. Executive Summary & Demo Scenario

This document details the exact end-to-end scenario showcased in the Enheduanna video walkthrough. It documents how a real developer works across fragmented desktop applications, takes a break, and returns to instantly resume their work with zero manual context feeding.

### The Problem in Practice
Every day, developers multitask across code editors, documentation, problem sets, and video tutorials. Context decays rapidly over time:
- Terminal commands disappear into scrollback.
- Browser tabs multiply into dozens of disconnected windows.
- Unsaved notes and scratch files lack formal metadata.
- When interrupted or returning from a break, recovering state requires 10–15 minutes of manual reorientation.

---

## 2. Pre-Break Activity: The 40-Minute Scattered Session

Before taking a break, the developer spends ~40 minutes actively multitasking across five key desktop surfaces (recorded locally across **231 captures** by MemVision):

| Surface / App | Activity Description | Local Capture Footprint |
|---|---|---|
| **LeetCode (Browser)** | Practicing algorithmic problem solving and debugging solution test cases. | Captured page titles, problem prompt, and editor code snippets. |
| **Wikipedia (Browser)** | Reading deep historical background on ancient Mesopotamia, Sumer, and the world's first named poet, Enheduanna of Ur. | Captured specific article headings, timeline charts, and paragraph text. |
| **Assignment PDF (Browser / Viewer)** | Working through a university / course assignment document with specific problem requirements. | Captured assignment title, problem prompt, and current page. |
| **YouTube (Browser)** | Watching an OBS Studio tutorial on setup and recording configurations. | Captured video player title, channel, and UI controls. |
| **VS Code (Full Screen)** | Editing a working draft notes file (`.md`) without explicitly saving a memorable path or naming it to any external tool. | Captured editor window content, active buffers, and terminal panels. |

During this entire session, MemVision captures screen states locally at ~1 Hz (with duplicate-frame skip), runs local WinRT OCR, and indexes full-text tokens into SQLite FTS5. All sensitive applications (such as password managers or banking tabs) are masked at the OS window boundary before OCR ever runs.

---

## 3. The Break: Context Decays, Memory Persists

The developer locks their workstation and steps away for a break:
- Active tabs sit idle or get buried behind full-screen applications.
- Mental state and active focus reset.
- In traditional setups, returning requires re-reading open tabs, re-searching browser history, hunting for the right VS Code tab, and manually reconstructing what was left unfinished.

---

## 4. Post-Break Recovery: Zero-Resistance Interaction

The developer returns to the desk and opens Enheduanna's local dashboard (`http://localhost:4100`).

### Step 1: Zero-Context Recall
> **User Prompt:**  
> *"I just came back from a break. What was I working on before I left?"*

- **Enheduanna's Action:**
  - Invokes `memvision.search_desktop_history` with query parameters targeting the last 40 minutes across the local SQLite FTS5 database.
  - Reconstructs the complete session timeline from **231 captures**:
    1. Identifies the active LeetCode question and debugging state.
    2. Identifies the Wikipedia article on Sumer and the exact section being read.
    3. Cites the assignment PDF document and current section.
    4. Identifies the OBS Studio tutorial watched on YouTube.
    5. Cites the active markdown draft in full-screen VS Code.
- **Enheduanna's Response:**
  - Delivers a concise chronological briefing of the past 40 minutes, mapping out exactly where the user left off with zero manual context feeding required.

---

### Step 2: Restoring Exact Pages & Deep State
> **User Prompt:**  
> *"Reopen the places I was looking at so I can pick up where I left off."*

- **Enheduanna's Action:**
  - Uses retrieved URLs and section anchors from memory.
  - Reopens the browser directly to the LeetCode problem.
  - Opens the Sumer Wikipedia page scrolled directly to the historical timeline section.
  - Re-launches the assignment PDF viewer.

---

### Step 3: Finding and Editing an Unnamed File
> **User Prompt:**  
> *"Find the notes file I had open in full-screen VS Code and add a summary of the Sumer timeline to it."*

- **Enheduanna's Action:**
  - The user never provided a file path or formal filename.
  - Enheduanna inspects the captured OCR text of the full-screen VS Code session, identifying the buffer name, surrounding folder structure, and workspace context.
  - Resolves the exact workspace path on disk.
  - Prepares the requested summary edit.

---

### Step 4: Governed Action & Human-in-the-Loop Consent
Before touching the disk or executing shell modifications:
- **Enheduanna Pauses Execution:**
  - An interactive **Authorization Required** dialog appears on the dashboard with a 120-second countdown timer.
  - Displays the exact target tool, path parameters, and operation diff.
- **User Decides:**
  - User clicks **Allow**. (If ignored for 120 seconds, the policy engine auto-denies the action).
  - The edit is applied to the markdown file.
  - An immutable audit entry is committed to the local audit log.

---

### Step 5: Live Screen Clarification with IGI
> **User Action:**  
> The developer spots a complex timeline diagram on the Wikipedia page and wants immediate explanation without switching back to a chatbot prompt.

- **Developer:** Presses `Ctrl+Shift+Q` to freeze the screen with the IGI visual overlay.
- **Interaction:** The developer circles the Sumerian chronological chart with the cursor.
- **IGI Local Snapping:** Local Sobel edge detection automatically snaps to the pixel-perfect bounding box of the chart, crops the subregion, and passes it to the Meta Llama 3.2 Vision model.
- **Result:** Igi streams an instant multimodal explanation of *just* the circled chart, answering the user's visual question in real-time.

---

## 5. Summary of Demo Capabilities Verified

| Capability | What Happened in the Scenario | Verification Mechanism |
|---|---|---|
| **Timeline Reconstruction** | Rebuilt 40 minutes of scattered activity from 231 captures | Local WinRT OCR + SQLite FTS5 query |
| **Zero-Context Retrieval** | User provided zero URLs, filenames, or prompts upfront | Pure memory lookup from background desktop captures |
| **Deep URL & Document Restoration** | Restored LeetCode, exact Sumer section, and assignment PDF | Browser launch via governed tool execution |
| **Blind File Identification** | Identified and modified an unnamed file with VS Code full screen | Visual buffer title extraction + workspace resolution |
| **Interactive Safety Gate** | Paused write operation for explicit user approval (120s auto-deny) | CLI-Bridge human-in-the-loop permission gate |
| **Immutable Audit Logging** | Logged every action, approval status, and command execution | Local audit trail (`audit.jsonl`) |
| **Real-time Snapping (IGI)** | Circled a timeline chart via `Ctrl+Shift+Q` and received instant vision diagnosis | Sobel edge snapping + Meta Llama 3.2 Vision |
