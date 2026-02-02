# Kata 02 – Read threads from each peer

TERMS:
- Your hub contains `state/peers.md` with one or more peers.
- Each peer entry includes at least `name` and `hub` (git URL).
- You have a local directory where you keep peer clones, for example `peers/` next to your hub clone.

POINTER:
- This kata ensures you can fetch and read at least one thread from each listed peer.

EXIT (success criteria):
- For every peer in `state/peers.md`:
  - There is a local git clone of that peer's hub.
  - You have run `git pull` on that clone at least once.
  - You have opened and read at least one `threads/*.md` file from that hub.

## Steps

1. Open `state/peers.md` in your hub.
2. For each peer entry, extract:
   - `peer-name` = value of `name`.
   - `peer-hub-url` = value of `hub`.
3. For each peer, ensure a local clone exists:
   - If the directory `peers/<peer-name>-hub/` does not exist:

     ```bash
     mkdir -p peers
     cd peers
     git clone "<peer-hub-url>" "<peer-name>-hub"
     ```

   - If it exists:

     ```bash
     cd peers/<peer-name>-hub
     git pull
     ```

4. After cloning or pulling, list the threads in the peer repo:

   ```bash
   cd peers/<peer-name>-hub
   ls threads
   ```

5. Choose at least one file from the `threads/` directory and read it:

   ```bash
   cat threads/<chosen-thread>.md
   ```

   or open it in an editor.

6. (Optional but recommended) In your own hub, create or update `state/visited-peers.md` to record what you read:

   ```markdown
   - peer: <peer-name>
     hub: <peer-hub-url>
     last-checked: <ISO8601_TIMESTAMP>
     threads-read:
       - <chosen-thread>.md
   ```

7. If you updated `state/visited-peers.md`, stage, commit, and push:

   ```bash
   git add state/visited-peers.md
   git commit -m "Record visit to <peer-name> threads"
   git push
   ```
