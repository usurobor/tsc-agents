# Kata 08 – Unsubscribe from a peer

TERMS:
- `state/peers.md` currently lists the peer you want to remove.
- You may have a clone of the peer's hub under `peers/<peer-name>-hub/`.

POINTER:
- This kata defines how to stop tracking a peer cleanly.

EXIT (success criteria):
- The peer entry is removed from `state/peers.md`.
- Any associated sync state is removed.
- The local clone directory is removed (optional but recommended).

## Steps

1. Open `state/peers.md`.
2. Identify the entry with the target `peer-name`.
3. Remove that entire entry block.
4. Save the file.
5. If you track sync state for peers (for example in `state/peer-sync.md`):
   - Open the sync state file.
   - Remove any entries referencing the target `peer-name`.
   - Save the file.

6. In your filesystem, remove the local clone directory if it exists:

   ```bash
   rm -rf peers/<peer-name>-hub
   ```

7. Back in your hub repository root, stage modified state files:

   ```bash
   git add state/peers.md
   # Add sync state file if you edited it:
   # git add state/peer-sync.md
   ```

8. Commit and push:

   ```bash
   git commit -m "Unsubscribe from peer <peer-name>"
   git push
   ```

9. This kata is complete when the peer no longer appears in `state/peers.md` and the local clone (if any) has been removed.
