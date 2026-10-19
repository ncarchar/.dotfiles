---
name: action-sha-check
description: Verify GitHub Actions "uses:" references are valid commit SHAs and resolve tag names to their correct pinned SHAs. Use when pinning action versions, auditing workflows for unpinned tags, or after a workflow errors with "unable to resolve action".
---

# action-sha-check

Verify that `uses:` references in GitHub Actions workflows are real commit SHAs.
The implementation is `scripts/verify.sh` (relative to this skill directory).

## Usage

Run from the repository root (relative path arguments, including the default
`.github/`, resolve against the current working directory):

```bash
scripts/verify.sh                      # scan .github/
scripts/verify.sh .github/workflows    # scan a directory
scripts/verify.sh a.yml b.yml          # scan specific files
scripts/verify.sh --resolve .github    # pin floating @tag refs to their commit SHA
```

For each non-local `uses: <owner>/<repo>@<ref>` line the script prints one line:

- `MATCH <owner>/<repo>@<sha>` - the 40-hex SHA is a real commit of that repo.
- `MISMATCH <owner>/<repo>@<sha>` - the SHA does not exist as a commit.
- `UNPINNED <owner>/<repo>@<ref>` - the ref is not a 40-char SHA (branch or tag).
- With `--resolve`: `RESOLVED <owner>/<repo>@<tag> -> <sha>` where the tag is
  peeled to its commit SHA (annotated tags are peeled through `/git/tags/<sha>`).

## Notes

- Exit status is non-zero when any pin is invalid (MISMATCH, unpinned, or
  unresolved under `--resolve`), so it can gate a CI job.
- `GITHUB_TOKEN` or `GH_TOKEN` is sent as an `Authorization` header when set
  (required for private repos; avoids the 60/hr unauthenticated rate limit).
  It is not required for public repos.
- Local composite actions (`uses: ./...`) are skipped.
- Uses the GitHub REST API via `curl` + `jq`; no other dependencies. The API
  endpoint, not `git ls-remote`, is used because ls-remote is HTTPS-blocked
  in this environment.