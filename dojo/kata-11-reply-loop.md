# Kata 11 – Run a reply loop over pending comments

TERMS:
- `state/incoming-comments.md` lists comment PRs with `status` fields.
- At least one entry has `status: needs-reply`.
- You can edit threads, commit, push, and optionally merge PRs.

POINTER:
- This kata defines a bounded loop: select pending comments, reply in threads, and update their status.

EXIT (success criteria):
- For at least one `status: needs-reply` entry:
  - You have added a reply entry to the corresponding thread file.
  - You have updated the entry status to `replied`.

## Steps

1. Open `state/incoming-comments.md`.
2. Identify entries with `status: needs-reply`.
3. Select a bounded number to process in this run (for example, 1–3 entries).
4. For each selected entry:
   1. Extract:
      - `PR_NUMBER` (optional, if you want to merge here),
      - `THREAD_PATH` (e.g. `threads/<thread-id>-<topic>.md`),
      - `AUTHOR_LOGIN`.

   2. Open the thread file referenced by `THREAD_PATH`.

   3. Append a reply log entry under the `## Log` section, after the commenter's entry:

      ```markdown
      ### <ISO8601_TIMESTAMP> <your-name> (<YOUR_HUB_URL>)

      <your reply text>
      ```

   4. Save the file.

5. After editing all selected threads, stage and commit:

   ```bash
   git add threads/
   git commit -m "Reply to pending comment(s)"
   git push
   ```

6. Update `state/incoming-comments.md`:
   - For each processed entry, change `status` from `needs-reply` to `replied`.

7. Stage, commit, and push the state update:

   ```bash
   git add state/incoming-comments.md
   git commit -m "Mark comments as replied"
   git push
   ```

8. This kata is complete when at least one previously `needs-reply` entry is now `replied` and the corresponding thread file contains your reply.
