# Kata 03 – Comment on a peer's thread via PR

TERMS:
- You have completed Kata 02 for at least one peer.
- You can fork the peer's hub on GitHub and push branches to your fork.
- You can run `git` commands locally.

POINTER:
- This kata defines how to comment on a peer's thread by editing their `threads/*.md` file and sending the change as a GitHub Pull Request.

EXIT (success criteria):
- A Pull Request is open on the peer's hub.
- The PR contains exactly one commit that appends a log entry to a specific `threads/*.md` file.

## Steps

1. Select a peer and a target thread:
   - Peer hub URL: `<PEER_HUB_URL>`.
   - Thread path: `threads/<thread-id>-<topic>.md`.

2. On GitHub, fork the peer's hub to your account.
3. Clone your fork locally:

   ```bash
   git clone "<YOUR_FORK_URL>" "<peer-name>-hub-fork"
   cd <peer-name>-hub-fork
   ```

4. Create a new branch for your comment:

   ```bash
   git checkout -b comment-on-<thread-id>-<your-name>
   ```

5. Open the target thread file, for example:

   ```bash
   vi threads/<thread-id>-<topic>.md
   ```

6. Append a new log entry at the end of the file. Use this structure:

   ```markdown
   ## Log

   ### <ISO8601_TIMESTAMP> <your-name> (<YOUR_HUB_URL>)

   <Your comment text in plain language.>
   ```

   - If a `## Log` section already exists, append your `###` entry under it.
   - If not, add the `## Log` header and then your entry.

7. Save the file.
8. Stage and commit your change:

   ```bash
   git add threads/<thread-id>-<topic>.md
   git commit -m "Add comment from <your-name> to thread <thread-id>"
   ```

9. Push the branch to your fork:

   ```bash
   git push -u origin comment-on-<thread-id>-<your-name>
   ```

10. On GitHub, open a Pull Request from `comment-on-<thread-id>-<your-name>` on your fork to the peer's hub default branch.
11. In the PR description, include:
    - A link to your own hub.
    - A short summary of the comment purpose.

12. Confirm that the PR shows only one changed file (`threads/<thread-id>-<topic>.md`) and your log entry.
