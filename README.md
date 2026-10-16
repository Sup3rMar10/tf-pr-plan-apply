# tf-pr-plan-apply

A Terraform pipeline for GitHub Actions: **every pull request gets a plan posted as a comment; a merge to `main` applies exactly the plan that was reviewed.**

A local file stands in for a real resource (`hashicorp/local` provider), so the whole pipeline runs with no cloud account.

## Flow

```
pull request --> fmt -check, init, validate, plan --> plan posted as a PR comment
merge to main --> same checks and plan --> [environment: production] --> apply tfplan
```

## What was checked (2026-10-16)

- **Locally:** init, validate, plan, apply on Terraform 1.16.5.
- **On GitHub Actions:** the `main` run succeeded (plan job, then apply job). A throwaway pull request ([#1](../../pull/1), closed without merging) proved the **plan comment** step works.
- **Not tested:** a pull request from a fork (the token is read-only there, so the comment step would fail), required reviewers on the `production` environment (not configured), and anything against a real cloud.

## Decisions

- **Apply the saved plan** (`terraform apply tfplan`), not a fresh `apply`. What was reviewed is what runs; a fresh apply could differ if things changed in between.
- **`concurrency` with `cancel-in-progress: false`.** Two applies must never overlap, and a running apply must never be cancelled.
- **Least privilege:** `contents: read`, plus `pull-requests: write` only for the comment.
- **`terraform_wrapper: false`** so `terraform show` output is clean text.
- **Committed `.terraform.lock.hcl`** with hashes for five platforms, so CI and laptops use the same provider build.
- **`environment: production`** is the hook for approvals: add required reviewers in the repo settings and the apply job waits for a person.

## Honest limits

- **State is not persisted.** The apply job starts with empty local state on a fresh runner. That works for this demo; a real pipeline needs a remote backend with locking (see `tf-state-bootstrap`).
- **No cloud credentials.** For AWS the usual answer is OIDC federation to a role rather than stored keys; not built here.
- The plan comment is truncated at 60,000 characters.

MIT licensed.
