variable "project_id" {
 description = <<EOT
The ID of the project the branch policies are created in. Every policy in this
module is created under this project. IMMUTABLE on each policy — changing it
forces destroy/recreate. Wire from tf_mod_azuredevops_project (project_id output).
EOT
 type = string
}

variable "min_reviewers" {
 description = <<EOT
Minimum-reviewer branch policies, keyed by a caller-supplied stable string.
Requires a configurable number of approving reviewers on a pull request.
{
 "<key>" = {
 enabled = optional(bool, true) # policy active; false to stage it
 blocking = optional(bool, true) # required (true) vs advisory (false)
 settings = {
 reviewer_count = number # approvals required
 submitter_can_vote = optional(bool, false)
 last_pusher_cannot_approve = optional(bool, false)
 allow_completion_with_rejects_or_waits = optional(bool, false)
 on_push_reset_approved_votes = optional(bool, false)
 on_push_reset_all_votes = optional(bool, false) # implies on_push_reset_approved_votes
 on_each_iteration_require_vote = optional(bool, false)
 on_last_iteration_require_vote = optional(bool, false)
 scope = list(object({ # at least one entry
 repository_id = optional(string) # omit for all repos; must be null when match_type = DefaultBranch
 repository_ref = optional(string) # e.g. refs/heads/main (Exact) or refs/heads/releases (Prefix)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 reviewer_count = number
 submitter_can_vote = optional(bool, false)
 last_pusher_cannot_approve = optional(bool, false)
 allow_completion_with_rejects_or_waits = optional(bool, false)
 on_push_reset_approved_votes = optional(bool, false)
 on_push_reset_all_votes = optional(bool, false)
 on_each_iteration_require_vote = optional(bool, false)
 on_last_iteration_require_vote = optional(bool, false)
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.min_reviewers: length(v.settings.scope) > 0
 ])
 error_message = "Each min_reviewers policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.min_reviewers: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each min_reviewers scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}

variable "build_validation" {
 description = <<EOT
Build-validation branch policies, keyed by a caller-supplied stable string.
Requires a build/pipeline to succeed before a pull request can complete.
{
 "<key>" = {
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = {
 build_definition_id = number # the pipeline to run; wire from a build definition
 display_name = string # name shown on the PR policy
 manual_queue_only = optional(bool, false)
 queue_on_source_update_only = optional(bool, true)
 valid_duration = optional(number, 720) # minutes the build stays valid; 0 = never expires
 filename_patterns = optional(list(string)) # only run when matching files change; "!" excludes
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 build_definition_id = number
 display_name = string
 manual_queue_only = optional(bool, false)
 queue_on_source_update_only = optional(bool, true)
 valid_duration = optional(number, 720)
 filename_patterns = optional(list(string))
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.build_validation: length(v.settings.scope) > 0
 ])
 error_message = "Each build_validation policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.build_validation: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each build_validation scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}

variable "status_check" {
 description = <<EOT
Status-check branch policies, keyed by a caller-supplied stable string.
Requires an external status (posted via the status API) to pass before completion.
{
 "<key>" = {
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = {
 name = string # the status name to check
 genre = optional(string) # status genre (e.g. continuous-integration)
 author_id = optional(string) # identity authorized to post the status
 invalidate_on_update = optional(bool, false) # reset status on new changes
 applicability = optional(string, "default") # default | conditional
 display_name = optional(string)
 filename_patterns = optional(list(string)) # only apply when matching files change; "!" excludes
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 name = string
 genre = optional(string)
 author_id = optional(string)
 invalidate_on_update = optional(bool, false)
 applicability = optional(string, "default")
 display_name = optional(string)
 filename_patterns = optional(list(string))
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.status_check: length(v.settings.scope) > 0
 ])
 error_message = "Each status_check policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.status_check: contains(["default", "conditional"], v.settings.applicability)
 ])
 error_message = "Each status_check applicability must be one of: default, conditional."
 }

 validation {
 condition = alltrue([
 for k, v in var.status_check: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each status_check scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}

variable "merge_types" {
 description = <<EOT
Merge-type branch policies, keyed by a caller-supplied stable string.
Controls which merge strategies are allowed when completing a pull request.
{
 "<key>" = {
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = {
 allow_squash = optional(bool, false) # squash merge
 allow_rebase_and_fast_forward = optional(bool, false) # rebase + fast-forward
 allow_basic_no_fast_forward = optional(bool, false) # basic merge, no fast-forward
 allow_rebase_with_merge = optional(bool, false) # semi-linear merge
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 allow_squash = optional(bool, false)
 allow_rebase_and_fast_forward = optional(bool, false)
 allow_basic_no_fast_forward = optional(bool, false)
 allow_rebase_with_merge = optional(bool, false)
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.merge_types: length(v.settings.scope) > 0
 ])
 error_message = "Each merge_types policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.merge_types: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each merge_types scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}

variable "comment_resolution" {
 description = <<EOT
Comment-resolution branch policies, keyed by a caller-supplied stable string.
Requires all pull-request comments to be resolved before completion.
{
 "<key>" = {
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = {
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.comment_resolution: length(v.settings.scope) > 0
 ])
 error_message = "Each comment_resolution policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.comment_resolution: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each comment_resolution scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}

variable "auto_reviewers" {
 description = <<EOT
Automatically-included-reviewer branch policies, keyed by a caller-supplied stable string.
Adds specific reviewers to pull requests that touch matching paths.
{
 "<key>" = {
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = {
 auto_reviewer_ids = list(string) # reviewer user/group descriptors (at least one)
 path_filters = optional(list(string)) # paths that trigger the reviewers
 submitter_can_vote = optional(bool, false)
 message = optional(string) # note shown in the PR activity feed
 minimum_number_of_reviewers = optional(number, 1) # only effective when blocking = true
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 auto_reviewer_ids = list(string)
 path_filters = optional(list(string))
 submitter_can_vote = optional(bool, false)
 message = optional(string)
 minimum_number_of_reviewers = optional(number, 1)
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.auto_reviewers: length(v.settings.scope) > 0
 ])
 error_message = "Each auto_reviewers policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.auto_reviewers: length(v.settings.auto_reviewer_ids) > 0
 ])
 error_message = "Each auto_reviewers policy must supply at least one auto_reviewer_ids entry."
 }

 validation {
 condition = alltrue([
 for k, v in var.auto_reviewers: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each auto_reviewers scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}

variable "work_item_linking" {
 description = <<EOT
Work-item-linking branch policies, keyed by a caller-supplied stable string.
Requires pull requests to be associated with at least one work item.
{
 "<key>" = {
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = {
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact") # Exact | Prefix | DefaultBranch
 }))
 }
 }
}
EOT
 type = map(object({
 enabled = optional(bool, true)
 blocking = optional(bool, true)
 settings = object({
 scope = list(object({
 repository_id = optional(string)
 repository_ref = optional(string)
 match_type = optional(string, "Exact")
 }))
 })
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.work_item_linking: length(v.settings.scope) > 0
 ])
 error_message = "Each work_item_linking policy must define at least one scope block."
 }

 validation {
 condition = alltrue([
 for k, v in var.work_item_linking: alltrue([
 for s in v.settings.scope: contains(["Exact", "Prefix", "DefaultBranch"], s.match_type)
 ])
 ])
 error_message = "Each work_item_linking scope match_type must be one of: Exact, Prefix, DefaultBranch."
 }
}
