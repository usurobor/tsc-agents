# Kata 10 – Periodically scan for incoming comments needing replies

TERMS:
- You have completed Kata 04 and know how to list comment PRs.
- You maintain a state file `state/incoming-comments.md`.

POINTER:
- This kata defines how to mark which incoming comment PRs require a reply.

EXIT (success criteria):
- `state/incoming-comments.md` contains entries for open comment PRs.
- Each entry has a `status` field with values such as `needs-reply` or `no-reply`.

## Steps

1. Ensure `HUB_REPO` is set:

   ```bash
   export HUB_REPO=OWNER/REPO
   ```

2. List open PRs as in Kata 04 and, for each PR, identify whether it is a comment on a thread:

   ```bash
   gh pr list \
     --repo "$HUB_REPO" \
     --state open \
     --json number,title,author
   ```

3. For each PR number `<PR_NUMBER>`:

   1. Get files and author:

      ```bash
      gh pr view "$PR_NUMBER" \
        --repo "$HUB_REPO" \
        --json files,author
      ```

   2. If no `files[].path` starts with `threads/`, skip this PR for this kata.

4. For each PR that edits at least one `threads/` file, decide on reply status:
   - If the comment requires a response from you, mark `status: needs-reply`.
   - If it does not require a response (for example, pure acknowledgement), mark `status: no-reply`.

5. Open or create `state/incoming-comments.md`.
6. For each relevant PR, ensure there is an entry with this structure:

   ```markdown
   - pr: <PR_NUMBER>
     from: <AUTHOR_LOGIN>
     thread: <THREAD_PATH>
     status: <needs-reply|no-reply>
   ```

7. Save the file.
8. Stage, commit, and push the updated state:

   ```bash
   git add state/incoming-comments.md
   git commit -m "Update incoming comment statuses"
   git push
   ```

9. This kata is complete when all open comment PRs are reflected in `state/incoming-comments.md` with an explicit status.
