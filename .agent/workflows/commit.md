---
description: Smart Commit - Intelligent Git Commit Assistant
---

1. Capture and analyze changes
   - Run `git --no-pager diff HEAD` to see what changed.
   - Run `git status` to check for untracked files or unexpected states.

2. Run Quality Checks
   - If `docker-compose.yml` or similar files changed, run `docker compose config` to validate.
   - Check for secrets or `.env` files in the diff.

3. Stage Changes
   - Ask the user which files to stage or if they want to stage all changes (`git add -A`).
   - Run the appropriate `git add` command.

4. Generate Commit Message
   - Analyze the changes and generate a conventional commit message following the format: `type(scope): subject`.
   - Ensure the message is concise and descriptive.

5. Get Approval
   - Present the proposed commit message to the user.
   - Ask for explicit approval to proceed.

6. Commit
   - If approved, run `git commit -m "message"`.
   - Verify the commit was successful.
