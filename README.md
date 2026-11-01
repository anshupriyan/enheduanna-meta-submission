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
