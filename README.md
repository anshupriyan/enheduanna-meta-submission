<div align="center">

# **ENHEDUANNA**

### *Knows the past, governs the present, guides the future*

</div>

---

## The Problem

In this digital world, the human mind interacts with devices constantly, and a significant portion of the data it processes arrives through the internet and screens: videos you watched, files you read, commands you ran. But the mind forgets, and details blur. A week later you can't remember which video it was, who made it, or where you saved the file. Tracking all of that by hand is a job in itself, and nobody does it.

The AI we use every day has the same blind spot. It only knows what you tell it. Either you paste in the context yourself every time, or you have to work out which context it needs and feed it manually. The knowledge is scattered across your own activity, and the tools that could use it have no way to see it.

---

## Introducing Enheduanna

Enheduanna is an on-device Desktop Intelligence that gives AI the context you already lived, so you don't have to reconstruct it by hand.

Named after Enheduanna of Ur (c. 2300 BCE), the world's first known author, it does for your desktop what she did with clay tablets: it writes down what the mind would otherwise forget, in a form you can search and act on later.

- **It remembers, with memvision.** What you watched, read and opened on screen is captured continuously and made searchable, even a week later. Ask which video you watched, who made it, or where you saved a file, and it answers in plain language.
- **It acts, with [cli-bridge](https://github.com/anshupriyan/cli-bridge/tree/meta-hackathon).** It can find and read your files and run commands in the directories you allow, governed by a policy you control over both commands and directories. Anything allowed runs immediately, anything restricted is blocked, and anything unknown asks for your approval first. Every action is written to an audit log.
- **It sees what you point at, with IGI.** IGI (Sumerian for "eye") is an on-screen overlay. Circle anything on your screen and ask about that exact thing, in context: an error, a button, a diagram. <sub>*Your rough circle is tightened to nearby UI boundaries with fast local edge detection and matched against on-device OCR, so the model sees a clean crop of what you meant — not a sloppy outline.*</sub>

**Ask about anything you saw, then act on it.**

**Private by design:** Your screen memory stays on your machine. When you ask a question, Enheduanna sends the model only what's relevant to it: your question, the matching memory snippets or files it retrieved, and screenshots only when they're needed, either of what you circled with IGI or a saved one from memory that helps answer a question about your past.

---

> [!NOTE]
> **Pre-existing work disclosure.** The only work here that predates this hackathon is **[cli-bridge](https://github.com/anshupriyan/cli-bridge)**, my TypeScript/Node.js MCP server that gives an AI controlled shell and file access to a machine.
>
> **cli-bridge is not part of this repository.** None of its code or history is included here. It is downloaded separately as an external dependency during setup, from the [`meta-hackathon` branch](https://github.com/anshupriyan/cli-bridge/tree/meta-hackathon).
>
> - **Before I applied:** cli-bridge was published and limited to a single sandboxed workspace root, with ripgrep search and a local audit log.
> - **After I was selected, before the Oct 26 kickoff (Oct 23-24):** I added a policy mode so Enheduanna could work across the machine safely: multiple allowed directories, read-write or read-only access per directory, restricted directories, and restricted commands. Per the organizers, this counts as pre-existing work.
>
> **Every line of code in this repository was written after the kickoff.**

---

## Built with the Meta Model API

All reasoning runs through the Meta Model API (`https://api.meta.ai/v1/chat/completions`, streaming SSE). Enheduanna uses two Meta models with different jobs:

| Model | Role |
|---|---|
| `muse-spark-1.3` | **Tool agent.** Runs the loop and decides which tools to call, up to 16 steps with up to 5 tool calls in parallel per step |
| `muse-wonder-1.0` | **Synthesis.** Runs once at the end with tools disabled and writes the final answer from all the evidence gathered. If Wonder fails, Spark automatically takes over |

Spark is fast at deciding and calling tools. Wonder is better at long, detailed answers over memory, files and screenshots, so each model does the part it's best at.

- **Tool calling over MCP.** 24 tools are exposed to the model as function tools: 9 from memvision, 14 from cli-bridge, and 1 internal (`get_full_result`). Calls within a step run in parallel, and one failing call doesn't stop the others.
- **Large results.** Tool results are truncated at 64 KB (128 KB for `read_file`) and retrievable in full through `get_full_result`, so big OCR dumps and files don't fill the context window.
- **Vision.** Screenshots from memory and IGI crops are sent as images. Only the 3 most recent stay in context, and older ones are replaced with a text placeholder.
- **Reasoning.** The model's reasoning is streamed live to the dashboard's Thinking drawer.

```json
"model": {
  "provider": "meta",
  "toolModel": "muse-spark-1.3",
  "synthesisModel": "muse-wonder-1.0",
  "baseUrl": "https://api.meta.ai/v1",
  "apiKey": "YOUR_META_API_KEY_HERE"
}
```

Set your key in `META_API_KEY` (PowerShell or `.env`), in `enheduanna.config.json`, or in the dashboard's Settings. It is saved only on your machine and never sent back to the browser. See [Setup](#setup) for the exact steps.

---

## Architecture

Everything runs on your machine except the calls to the Meta Model API. **Core** is the hub: the dashboard and IGI talk to it, and it talks to memory, actions and the models.

```mermaid
flowchart LR
    D["Dashboard<br/>(served by Core)"] -->|"POST /chat · SSE"| C
    I["IGI overlay<br/>Ctrl+Shift+Q"] -->|"POST /chat + crop"| C
    C["Core :4100<br/>agent loop · MCP hub · trace"]
    C <-->|"stdio MCP"| M["memvision"]
    C <-->|"stdio MCP"| P{{"policy<br/>allow · ask · block"}}
    P <--> B["cli-bridge"]
    C -->|"HTTPS · streaming"| A["Meta Model API<br/>Spark + Wonder"]
    M --> S[("SQLite FTS5<br/>+ WebP screenshots")]
    V["Capture monitor :8765"] -.->|reads| S
```

| Arrow | What travels |
|---|---|
| Dashboard → Core | `POST /chat`, trace stream (SSE), tool list, approval responses |
| IGI → Core | `POST /chat` with the cropped image, window title, folder, page URL and on-screen text; the answer streams back to IGI |
| Core → memvision / cli-bridge | MCP over stdio: `tools/list`, `tools/call` |
| Core → Meta | Streaming chat completions (models and limits: [Built with the Meta Model API](#built-with-the-meta-model-api)) |
| Dashboard toggle → capture | Turning recording on or off starts or stops the capture loop, separate from the MCP tools |

### How a request flows

**A. Chat: "What video did I watch yesterday?"**
1. You ask in the dashboard, which sends the question to Core.
2. Spark decides what it needs and calls memvision's search tools.
3. Matching captures (OCR text, window titles, screenshots if needed) come back as tool results.
4. If it needs a file, Spark calls cli-bridge. Allowed paths run, restricted ones are blocked, and unknown ones ask you for approval.
5. Wonder gets all the evidence with tools disabled and writes the answer, streamed back to you.

**B. Circle: "What's this error?"**
1. Press the hotkey. The overlay freezes your screen and you circle the area.
2. IGI snaps your rough circle to nearby UI edges and reads the text with Windows OCR, entirely on-device.
3. IGI sends the crop, with the window title and context, to Core.
4. From here it follows the same Core loop as flow A, and the answer streams back to IGI's panel.

**C. Capture: when recording is on, independent of chat**
1. memvision takes a screenshot of your screen.
2. A privacy gate filters what's captured.
3. The text is read with Windows OCR.
4. The result is stored in a local SQLite database with full-text search, alongside compressed screenshots on disk.

### Components

| Component | Role | Details |
|---|---|---|
| **Core** (`app/core/`, `app/dashboard/`) | Server, agent loop, MCP hub, trace, approvals | [docs/ARCHITECTURE.md#core--server-agent-loop-mcp-hub-appcore--appdashboard](docs/ARCHITECTURE.md#core--server-agent-loop-mcp-hub-appcore--appdashboard) |
| **memvision** (`memvison/`) | Continuous screen memory, with 9 MCP tools | [docs/ARCHITECTURE.md#memvision-continuous-screen-memory-memvison](docs/ARCHITECTURE.md#memvision-continuous-screen-memory-memvison) |
| **IGI** (`igi/`) | Circle-to-ask overlay: local edge snapping plus WinRT OCR, no cloud segmentation | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| **cli-bridge** | Policy-gated file and terminal actions over MCP (14 tools), with an audit log. Pre-existing work (see the note at the top), cloned by setup as a sibling `../cli-bridge` dependency and not part of this repo | [cli-bridge](https://github.com/anshupriyan/cli-bridge/tree/meta-hackathon) |

### Ports and trust boundary

| Port | Service |
|---|---|
| `4100` | Core and dashboard |
| `8765` | memvision capture monitor (timeline viewer) |
| none | IGI talks to Core on `4100` |

Everything listens on `127.0.0.1`. Your screen memory stays on your machine, and the only traffic that leaves it is calls to the Meta Model API. Your API key is never returned to the browser.

### Repo map

| Path | What's in it |
|---|---|
| `app/` | Core server, agent loop, dashboard |
| `memvison/` | memvision: screen memory, OCR, search, MCP server |
| `igi/` | IGI overlay. The `sam/` folder and file names are legacy from an early SAM-based design; the current snapping is local edge detection plus WinRT OCR, with no SAM model involved |
| `scripts/` | Setup and run scripts |
| `docs/` | Deeper notes |
