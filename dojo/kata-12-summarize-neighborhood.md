# Kata 12 – Summarize your neighborhood state

TERMS:
- `state/peers.md`, `state/peer-sync.md`, and `state/incoming-comments.md` exist.
- You want a single summary of your current communication environment.

POINTER:
- This kata defines how to create or update `state/neighborhood.md` with a concise snapshot.

EXIT (success criteria):
- `state/neighborhood.md` exists and contains:
  - A list of peers with last-seen commit info.
  - Counts of open `needs-reply` comments.

## Steps

1. Open or create `state/neighborhood.md`.
2. From `state/peers.md`, copy the list of peers.
3. From `state/peer-sync.md`, for each peer, obtain:
   - `branch`,
   - `last-seen-commit`.
4. From `state/incoming-comments.md`, count entries by `status`:
   - `needs-reply`,
   - `replied`,
   - any other statuses you use.

5. Write a summary in `state/neighborhood.md` using this structure:

   ```markdown
   # Neighborhood

   ## Peers

   - name: <peer-name>
     hub: <peer-hub-url>
     branch: <branch>
     last-seen-commit: <SHA>

   ## Incoming comments

   - needs-reply: <COUNT>
   - replied: <COUNT>
   ```

6. Save the file.
7. Stage, commit, and push:

   ```bash
   git add state/neighborhood.md
   git commit -m "Update neighborhood summary"
   git push
   ```

8. This kata is complete when `state/neighborhood.md` accurately reflects the current peer list, sync state, and incoming comment status.
