# ─────────────────────────────────────────────────────────────────────────────
# tf_mod_azuredevops_branch_policies — aggregation module
#
# No primary `this` resource. Each branch_policy_* type is an independently
# optional, named for_each collection scoped to repositories/branches within
# var.project_id. Callers use any, all, or none of the collections.
# ─────────────────────────────────────────────────────────────────────────────

resource "azuredevops_branch_policy_min_reviewers" "min_reviewers" {
 for_each = var.min_reviewers

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 reviewer_count = each.value.settings.reviewer_count
 submitter_can_vote = each.value.settings.submitter_can_vote
 last_pusher_cannot_approve = each.value.settings.last_pusher_cannot_approve
 allow_completion_with_rejects_or_waits = each.value.settings.allow_completion_with_rejects_or_waits
 on_push_reset_approved_votes = each.value.settings.on_push_reset_approved_votes
 on_push_reset_all_votes = each.value.settings.on_push_reset_all_votes
 on_each_iteration_require_vote = each.value.settings.on_each_iteration_require_vote
 on_last_iteration_require_vote = each.value.settings.on_last_iteration_require_vote

 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}

resource "azuredevops_branch_policy_build_validation" "build_validation" {
 for_each = var.build_validation

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 build_definition_id = each.value.settings.build_definition_id
 display_name = each.value.settings.display_name
 manual_queue_only = each.value.settings.manual_queue_only
 queue_on_source_update_only = each.value.settings.queue_on_source_update_only
 valid_duration = each.value.settings.valid_duration
 filename_patterns = try(each.value.settings.filename_patterns, null)

 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}

resource "azuredevops_branch_policy_status_check" "status_check" {
 for_each = var.status_check

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 name = each.value.settings.name
 genre = try(each.value.settings.genre, null)
 author_id = try(each.value.settings.author_id, null)
 invalidate_on_update = each.value.settings.invalidate_on_update
 applicability = each.value.settings.applicability
 display_name = try(each.value.settings.display_name, null)
 filename_patterns = try(each.value.settings.filename_patterns, null)

 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}

resource "azuredevops_branch_policy_merge_types" "merge_types" {
 for_each = var.merge_types

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 allow_squash = each.value.settings.allow_squash
 allow_rebase_and_fast_forward = each.value.settings.allow_rebase_and_fast_forward
 allow_basic_no_fast_forward = each.value.settings.allow_basic_no_fast_forward
 allow_rebase_with_merge = each.value.settings.allow_rebase_with_merge

 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}

resource "azuredevops_branch_policy_comment_resolution" "comment_resolution" {
 for_each = var.comment_resolution

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}

resource "azuredevops_branch_policy_auto_reviewers" "auto_reviewers" {
 for_each = var.auto_reviewers

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 auto_reviewer_ids = each.value.settings.auto_reviewer_ids
 path_filters = try(each.value.settings.path_filters, null)
 submitter_can_vote = each.value.settings.submitter_can_vote
 message = try(each.value.settings.message, null)
 minimum_number_of_reviewers = each.value.settings.minimum_number_of_reviewers

 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}

resource "azuredevops_branch_policy_work_item_linking" "work_item_linking" {
 for_each = var.work_item_linking

 project_id = var.project_id
 enabled = each.value.enabled
 blocking = each.value.blocking

 settings {
 dynamic "scope" {
 for_each = each.value.settings.scope
 content {
 repository_id = try(scope.value.repository_id, null)
 repository_ref = try(scope.value.repository_ref, null)
 match_type = try(scope.value.match_type, "Exact")
 }
 }
 }
}
