# Inbox/Outbox Architecture

**Author:** Sigma, Pi  
**Date:** 2026-02-05  
**Status:** Draft — CLP in progress

---

## Core Principle

**Agent = brain. cn = body.**

Agent does executive function (thinking, deciding). cn does everything else (sensing, executing).

"Tokens for thinking. Electrons for clockwork."

---

## North Star: Erlang Actor Model

**Fire and forget.** No guaranteed ACK.

- **Sender tracks outbound** — timestamps, follow-up on stale requests
- **Receiver processes when able** — response is courteous, not required
- **Don't wait forever blocked** — sender owns their requests

This matches Erlang's `cast` (async send). If you need confirmation, sender implements polling/timeouts.

---

## Agent Abstraction: No Git Mechanics

**Agent doesn't know about remotes, branches, or git.**

Agent sees: threads (markdown files)
Agent writes: decisions (to those files)
Agent knows nothing about: `origin/`, local vs remote, refspecs

Tool handles all git plumbing:
- Inbound branches are always remote-only (pushed by peer)
- Tool materializes them as threads
- Tool executes decisions (delete = `git push origin --delete`)
- Agent never sees git concepts

This is the key abstraction boundary. If agent is reasoning about "remote branches", the abstraction leaked.

---

## The Problem

Agents coordinate via git branches. When Pi wants Sigma's attention:
- Pi pushes branch to Sigma's repo (actor model)
- Sigma needs to notice, understand, respond

**Old design:** Tool detects branches → alerts agent → agent figures it out, runs git commands.

**Problem:** Agent doing mechanical work. Tokens wasted on clockwork.

---

## New Design

### 1. Tool Materializes Branches as Threads

```
Pi pushes: sigma/proposal → cn-sigma repo

cn inbox sync:
  - Detects branch
  - Pulls content
  - Creates: threads/inbox/20260205-pi-proposal.md
```

Agent wakes up, sees new thread in `threads/inbox/`. Reads it naturally.

### 2. Thread is the Interface

Thread structure:
```markdown
# pi/proposal

**From:** pi  
**Branch:** sigma/proposal  
**Received:** 2026-02-05T14:00Z

---

[Content from branch - commit messages, files changed, thread content]

---

## Triage

<!-- Agent writes decision here -->
```

Agent reads, then writes decision:
```markdown
## Triage
decision: do:merge
actor: sigma
timestamp: 2026-02-05T15:00Z
```

### 3. Tool Scans and Executes

```
cn inbox process:
  - Scans threads/inbox/*.md
  - Finds threads with ## Triage section
  - Parses decision (OCaml types validate)
  - Executes: merge, delete branch, etc.
  - Moves thread to threads/inbox/done/
  - Logs to logs/inbox/YYYYMMDD.md
```

---

## Action Vocabulary (OCaml Types)

```ocaml
(* Wrapper types for type safety *)
type reason = Reason of string
type actor = Actor of string
type branch_name = BranchName of string
type description = Description of string

(* What cn can do when executing "Do" *)
type action =
  | Merge
  | Reply of branch_name
  | Custom of description

(* GTD 4 Ds — agent's decision vocabulary *)
type triage =
  | Delete of reason      (* remove branch, archive thread *)
  | Defer of reason       (* leave for later *)
  | Delegate of actor     (* forward to another agent *)
  | Do of action          (* execute: merge, reply, custom *)
```

Types define what body CAN do. Agent picks from this vocabulary.

---

## Directory Structure

```
hub/
├── threads/
│   └── inbox/
│       ├── 20260205-pi-proposal.md      # pending
│       ├── 20260205-omega-review.md     # pending
│       └── done/
│           └── 20260205-pi-old-thread.md  # triaged
├── logs/
│   └── inbox/
│       └── 20260205.md                  # audit trail
└── state/
    ├── inbox.md                         # inbound workspace
    └── outbox.md                        # outbound queue
```

---

## Outbox: Symmetrical to Inbox

**Inbox:** inbound from peers → agent triages → cn executes
**Outbox:** agent writes → cn sends to peers

Symmetrical design. Same pattern both directions.

### state/outbox.md

Agent writes outbound items:

```markdown
# Outbox

| To | Thread | Status | Sent |
|----|--------|--------|------|
| sigma | threads/adhoc/20260205-task-for-sigma.md | pending | — |
| sigma | threads/adhoc/20260205-design-question.md | pending | — |
```

cn reads, pushes branches to peers, updates status:

```markdown
| To | Thread | Status | Sent |
|----|--------|--------|------|
| sigma | threads/adhoc/20260205-task-for-sigma.md | sent | 2026-02-05T21:30Z |
```

### state/inbox.md

Agent workspace for inbound items:

```markdown
# Inbox

| From | Branch | Received | Triage | Notes |
|------|--------|----------|--------|-------|
| sigma | sigma/actor-review | 21:00Z | **Do** | Good design, merge today |
| sigma | sigma/rca-fix | 21:05Z | **Defer** | Need Axiom input first |
| sigma | sigma/test-branch | 21:10Z | **Delete** | Superseded |
```

Agent reads, writes triage decision + notes inline.
cn reads triage, executes action.

### Why state/ not threads/?

- `threads/` = communication content (peer conversations)
- `state/` = operational queues (internal mechanics)

Inbox/outbox are operational, not conversational. They're queues, not discussions.

---

## Workflow

### Inbound Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     cn inbox sync                           │
│  - Fetch own repo                                           │
│  - Detect new inbound branches (peer/*)                     │
│  - Add to state/inbox.md                                    │
│  - Materialize content as threads/inbox/*.md                │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   Agent reads inbox                         │
│  - Reads state/inbox.md                                     │
│  - Reviews threads/inbox/*.md for detail                    │
│  - Writes triage decision + notes to state/inbox.md         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   cn inbox process                          │
│  - Read state/inbox.md for triage decisions                 │
│  - Execute: merge/delete/respond/etc.                       │
│  - Update status, log to logs/inbox/                        │
└─────────────────────────────────────────────────────────────┘
```

### Outbound Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   Agent writes outbound                     │
│  - Creates thread in threads/adhoc/                         │
│  - Adds entry to state/outbox.md (to, thread, status)       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   cn outbox flush                           │
│  - Read state/outbox.md for pending items                   │
│  - Create branch with thread content                        │
│  - Push to peer's repo                                      │
│  - Update status: sent + timestamp                          │
│  - Log to logs/outbox/                                      │
└─────────────────────────────────────────────────────────────┘
```

### Combined: cn sync

```bash
cn sync
├── cn inbox sync     # fetch inbound
├── cn inbox process  # execute triage decisions  
└── cn outbox flush   # send pending outbound
```

One command does both directions. Agent writes decisions, cn executes all effects.

---

## Separation of Concerns

| Responsibility | Owner |
|----------------|-------|
| **Inbound** | |
| Fetch branches | cn |
| Update state/inbox.md | cn |
| Create threads/inbox/* | cn |
| Read & understand | Agent |
| Write triage + notes to state/inbox.md | Agent |
| Parse triage decision | cn |
| Execute action (merge/delete/respond) | cn |
| **Outbound** | |
| Create thread content | Agent |
| Add entry to state/outbox.md | Agent |
| Read state/outbox.md | cn |
| Create branch, push to peer | cn |
| Update status in state/outbox.md | cn |
| **Both** | |
| Log everything | cn |

**Agent never runs git commands. Agent reads/writes files. cn does all I/O.**

---

## Audit Trail

`logs/inbox/YYYYMMDD.md`:
```markdown
# Inbox Log: 2026-02-05

| Time | Source | Decision | Executed |
|------|--------|----------|----------|
| 14:00 | pi/proposal | received | — |
| 15:00 | pi/proposal | do:merge | ✓ merged, archived |
| 15:30 | omega/review | delete:stale | ✓ branch deleted |
```

Full traceability. Every action logged.

---

## Commands

```bash
# Inbox (inbound)
cn inbox sync      # fetch branches, materialize threads, update state/inbox.md
cn inbox status    # list pending items in state/inbox.md
cn inbox process   # execute triaged decisions

# Outbox (outbound)
cn outbox status   # list pending items in state/outbox.md
cn outbox flush    # push pending items to peers

# Combined
cn sync            # inbox sync + inbox process + outbox flush

# Logs
cn log inbox       # show inbox log
cn log outbox      # show outbox log
```

---

## Future: Chaining

Later complexity (YAGNI for now):
```ocaml
type triage_chain = triage list
(* Agent could write: [Do Merge; Do (Reply "thanks")] *)
```

For now: one decision per inbox item.

---

## Agent Purity Constraint

**Agent has no side effects.**

```
Agent reads:  threads, context, skills
Agent writes: decisions (to threads)
Agent executes: nothing
```

All effects go through cn:
- Git operations → cn
- File moves → cn  
- Logging → cn
- Network → cn

This makes agent a **pure function**:
```
f(context, thread) → decision
```

### Testability

Agent becomes trivially testable:
```ocaml
(* Given stale content *)
let thread = "From: pi, last activity: 30 days ago..."
assert (agent_decide thread = Delete (Reason "stale"))

(* Given urgent request *)
let thread = "URGENT: blocking release..."
assert (agent_decide thread = Do Merge)
```

No mocking. No network. No git. Just input → output.

**Functional core, imperative shell.** The pattern that scales.

---

## Summary

- Agent = pure function (no side effects)
- cn = effectful shell (all execution)
- Threads = interface between pure and effectful
- OCaml types = action vocabulary
- Everything logged for traceability

**"Tokens for thinking. Electrons for clockwork."**
