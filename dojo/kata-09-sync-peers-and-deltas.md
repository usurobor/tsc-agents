# Kata 09 – Sync all peers and record last-seen commits

TERMS:
- `state/peers.md` lists one or more peers.
- You store per-peer sync state in `state/peer-sync.md`.
- Each peer hub has a local clone under `peers/<peer-name>-hub/`.

POINTER:
- This kata defines how to pull updates from all peers and record, per peer, the last commit you have seen on the main branch.

EXIT (success criteria):
- `state/peer-sync.md` exists.
- For every peer in `state/peers.md`, `state/peer-sync.md` has an entry with:
  - `peer` (name),
  - `hub` (URL),
  - `branch` (e.g. `main`),
  - `last-seen-commit` (SHA).

## Steps

1. Ensure `state/peer-sync.md` exists. If it does not, create an empty file:

   ```bash
   touch state/peer-sync.md
   ```

2. Open `state/peers.md` and collect all `peer-name` and `peer-hub-url` pairs.
3. For each peer:
   1. Change into the local clone directory:

      ```bash
      cd peers/<peer-name>-hub
      ```

   2. Pull the latest changes:

      ```bash
      git pull
      ```

   3. Identify the default branch. If you use `main` consistently, set:

      ```bash
      BRANCH=main
      ```

   4. Get the current HEAD commit SHA on that branch:

      ```bash
      git rev-parse "$BRANCH"
      ```

      Record this value as `<SHA>`.

   5. Return to your hub repository root.

   6. In `state/peer-sync.md`, ensure there is a single entry for this peer. The structure SHOULD be:

      ```markdown
      - peer: <peer-name>
        hub: <peer-hub-url>
        branch: <BRANCH>
        last-seen-commit: <SHA>
      ```

      - If an entry already exists, update `last-seen-commit` to `<SHA>`.
      - If none exists, append a new entry.

4. After processing all peers, stage and commit the updated sync state:

   ```bash
   git add state/peer-sync.md
   git commit -m "Sync peers and record last-seen commits"
   git push
   ```

5. This kata is complete when every peer in `state/peers.md` has a corresponding up-to-date entry in `state/peer-sync.md`.
