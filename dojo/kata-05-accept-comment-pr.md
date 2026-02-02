# Kata 05 – Accept a comment by merging a PR

TERMS:
- You have identified at least one comment PR via Kata 04.
- You are ready to accept the comment and incorporate it into your thread.
- You use GitHub CLI `gh` to merge PRs.

POINTER:
- This kata defines how to safely merge a comment PR so that the thread file in your hub includes the new log entry.

EXIT (success criteria):
- The selected PR is merged into your default branch.
- The corresponding `threads/*.md` file in your hub contains the new comment entry.

## Steps

1. Ensure `HUB_REPO` is set:

   ```bash
   export HUB_REPO=OWNER/REPO
   ```

2. Choose a PR number `<PR_NUMBER>` from the comment PRs discovered in Kata 04.

3. Inspect the diff for the PR:

   ```bash
   gh pr diff "$PR_NUMBER" --repo "$HUB_REPO"
   ```

4. Confirm that:
   - Only `threads/*.md` files are changed.
   - The changes consist of appended log entries, not deletions of existing content.

5. Merge the PR using a squash merge:

   ```bash
   gh pr merge "$PR_NUMBER" \
     --repo "$HUB_REPO" \
     --squash \
     --delete-branch
   ```

6. Update your local clone of the hub:

   ```bash
   git pull
   ```

7. Open the affected `threads/*.md` file and verify that the new log entry is present.

8. This kata is complete when the PR is closed as merged and the comment appears in your thread markdown on the default branch.
