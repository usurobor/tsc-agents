# CN Logging Architecture

**Status:** Implementation  
**Created:** 2026-02-05

---

## Principle

cn does all effects. cn logs all effects. Agent is traceable without reading git history.

## Log Location

```
logs/
├── cn.log           ← append-only action log
├── inbox/           ← per-day inbox logs
│   └── 20260205.md
└── outbox/          ← per-day outbox logs
    └── 20260205.md
```

## Log Format (cn.log)

Append-only, one JSON line per action:

```jsonl
{"ts":"2026-02-05T22:04:00Z","action":"inbox.fetch","peer":"pi","branches":["pi/inbox-outbox-clp"]}
{"ts":"2026-02-05T22:04:01Z","action":"inbox.materialize","branch":"pi/inbox-outbox-clp","thread":"threads/inbox/pi-inbox-outbox-clp.md"}
{"ts":"2026-02-05T22:05:00Z","action":"outbox.send","to":"pi","thread":"threads/outbox/review.md","branch":"sigma/review"}
{"ts":"2026-02-05T22:05:01Z","action":"outbox.push","remote":"cn-pi","branch":"sigma/review","result":"ok"}
```

## Human-Readable Logs (inbox/outbox dirs)

Daily markdown summaries:

```markdown
# Inbox Log: 2026-02-05

## 22:04 — Fetched from pi
- pi/inbox-outbox-clp → threads/inbox/pi-inbox-outbox-clp.md

## 22:15 — Reply detected
- threads/inbox/pi-inbox-outbox-clp.md has new content
- Sent response: sigma/inbox-outbox-clp-reply
```

## Traceability

Every effect has:
- **Timestamp** — when it happened
- **Action** — what cn did
- **Input** — what triggered it (branch, thread, etc.)
- **Output** — what resulted (new file, pushed branch, etc.)
- **Result** — ok / error + details

Agent can read logs to understand what happened without touching git.

## Implementation

```javascript
function logAction(action, details) {
  const entry = {
    ts: new Date().toISOString(),
    action,
    ...details
  };
  fs.appendFileSync(
    path.join(hubPath, 'logs', 'cn.log'),
    JSON.stringify(entry) + '\n'
  );
}
```

Called on every cn effect: fetch, materialize, send, push, delete, etc.
