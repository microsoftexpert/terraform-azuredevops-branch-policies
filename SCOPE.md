# SCOPE — `terraform-azuredevops-branch-policies`

> **Module type:** `aggregation`  ·  **Provider:** `microsoft/azuredevops` (`>= 1.0, < 2.0`)  ·  **Scope:** project-scoped

Aggregation of branch protection policies. No primary resource. Each policy type is an independently-optional named collection scoped to repository/branch. Consumes project_id and repository_id.

---

## In-scope resources

**No primary `this` resource.** Each resource type is an independently-optional, named `for_each` collection. Callers use any, all, or none of the collections.

- `azuredevops_branch_policy_min_reviewers`
- `azuredevops_branch_policy_build_validation`
- `azuredevops_branch_policy_status_check`
- `azuredevops_branch_policy_merge_types`
- `azuredevops_branch_policy_comment_resolution`
- `azuredevops_branch_policy_auto_reviewers`
- `azuredevops_branch_policy_work_item_linking`

## Out-of-scope resources (consumed by ID)

- `azuredevops_project` — provided as `project_id` by `terraform-azuredevops-project`.
- `azuredevops_git_repository` — provided as `repository_id` by `terraform-azuredevops-git-repository`.

## Consumes

| Input | Type | Source module |
|---|---|---|
| `project_id` | string | `terraform-azuredevops-project` |
| `repository_id` | string | terraform-azuredevops-git-repository |

## Required Azure DevOps scopes / auth

Creating and editing branch policies requires the running identity to be a member of the
**Project Administrators** security group **or** to hold the repository-level **Edit policies**
permission on the target repository/branch (per Microsoft Learn, *Branch policies and settings*).

| Scope / Role | PAT scope | Service-principal role | Required for |
|---|---|---|---|
| Code | Code (Read, Write & Manage) | Project Administrators **or** repository-level **Edit policies** | creating/updating every `branch_policy_*` in this module |
| Build (read) | Build (Read) | — | resolving `build_definition_id` referenced by `build_validation` policies |

> ⚠️ Setting policies on a branch that already has *required* policies, or managing policies
> across all repositories in the project (project-wide scope, `repository_id = null`), effectively
> requires **Project Administrators**. Repository-level **Edit policies** only covers repos the
> identity has been granted it on.

## Emits

| Output | Description | Consumed by |
|---|---|---|
| `<role>_ids` | Map of branch-policy IDs keyed by policy role (e.g. min_reviewers_ids) | downstream modules / audit |
| `ids` | Flattened map of all managed resource IDs | audit / access review |

## Provider gotchas

- **Scope is per-policy, not per-module.** Each policy carries a repeating `scope` block (≥1 entry)
  with `repository_id` + `repository_ref` + `match_type`. There is **no** top-level `repository_id`
  on these resources, so this module exposes none — wire the repository ID into each scope.
- **`match_type`** is `Exact` (default), `Prefix`, or `DefaultBranch`. When `match_type = "DefaultBranch"`,
  do **not** set `repository_id`/`repository_ref` for that scope entry. `repository_id = null` (with
  `Exact`/`Prefix`) scopes the policy to **all** repositories in the project.
- **`build_validation`** requires a valid `build_definition_id` (number) — create the pipeline first
  (`terraform-azuredevops-build-definition`) and pass its ID. `valid_duration = 0` means the build never expires.
- **`auto_reviewers`** requires ≥1 reviewer descriptor in `auto_reviewer_ids`. `minimum_number_of_reviewers`
  only takes effect when `blocking = true`, and can exceed `1` only when `auto_reviewer_ids` is exactly one group.
- **`status_check.applicability`** is `default` or `conditional`; `conditional` applies the policy only
  after a status has been posted to the PR.
- **`min_reviewers`**: setting `on_push_reset_all_votes = true` implicitly forces `on_push_reset_approved_votes = true`.
- **No secrets.** No `branch_policy_*` field carries a credential, token, or key — no module input or output is `sensitive`.
- **No `timeouts` block.** The `branch_policy_*` resources do not expose Terraform operation timeouts, so the module omits a `timeouts` variable (confirmed against the provider schema during authoring).
- **Eventual consistency.** Policies are applied asynchronously; PRs opened immediately after `apply`
  may briefly not reflect a newly created policy.

## Design decisions

- Aggregation: each branch_policy_* type is an independently-optional named collection.
- Separated from git_repository because policies are often managed by a different (security) owner.

---

> Regenerate the RAG index after editing this file: `ingest_internal_standards_azuredevops.py`.
