# Kata 06 – Reply to a comment inside the same thread file

TERMS:
- You have merged at least one comment PR via Kata 05.
- The merged comment appears as a log entry in a `threads/*.md` file.
- You want to add your reply as another log entry in the same file.

POINTER:
- This kata defines how to reply to a comment by appending your own log entry to the thread file.

EXIT (success criteria):
- The same `threads/*.md` file contains:
  - The original commenter's log entry.
  - A new log entry from you, clearly marked and following the comment.

## Steps

1. Identify the thread file that contains the merged comment, for example:

   ```text
   threads/<thread-id>-<topic>.md
   ```

2. Open the file in your editor.
3. Scroll to the bottom of the `## Log` section where the commenter's entry appears, for example:

   ```markdown
   ## Log

   ### 2026-02-02T23:36Z commenter-name (https://commenter-hub.git)

   <comment text>
   ```

4. Immediately after the commenter's entry, append your reply entry:

   ```markdown
   ### <ISO8601_TIMESTAMP> <your-name> (<YOUR_HUB_URL>)

   <your reply text>
   ```

5. Save the file.
6. Stage and commit the change:

   ```bash
   git add threads/<thread-id>-<topic>.md
   git commit -m "Reply to <commenter-name> on thread <thread-id>"
   ```

7. Push the commit to the default branch:

   ```bash
   git push
   ```

8. Verify on the host (GitHub web view) that the thread file now shows your reply entry directly after the commenter's entry.
