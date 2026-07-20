output "min_reviewers_ids" {
 description = "Map of min-reviewer branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_min_reviewers.min_reviewers: k => v.id }
}

output "build_validation_ids" {
 description = "Map of build-validation branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_build_validation.build_validation: k => v.id }
}

output "status_check_ids" {
 description = "Map of status-check branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_status_check.status_check: k => v.id }
}

output "merge_types_ids" {
 description = "Map of merge-type branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_merge_types.merge_types: k => v.id }
}

output "comment_resolution_ids" {
 description = "Map of comment-resolution branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_comment_resolution.comment_resolution: k => v.id }
}

output "auto_reviewers_ids" {
 description = "Map of auto-reviewer branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_auto_reviewers.auto_reviewers: k => v.id }
}

output "work_item_linking_ids" {
 description = "Map of work-item-linking branch-policy IDs, keyed by collection key. Empty when the collection is unused."
 value = { for k, v in azuredevops_branch_policy_work_item_linking.work_item_linking: k => v.id }
}

output "ids" {
 description = <<EOT
Flattened map of every managed branch-policy ID, keyed by "<role>/<collection key>"
(e.g. "min_reviewers/main"). Useful for audit and access review across all collections.
EOT
 value = merge({ for k, v in azuredevops_branch_policy_min_reviewers.min_reviewers: "min_reviewers/${k}" => v.id },
 { for k, v in azuredevops_branch_policy_build_validation.build_validation: "build_validation/${k}" => v.id },
 { for k, v in azuredevops_branch_policy_status_check.status_check: "status_check/${k}" => v.id },
 { for k, v in azuredevops_branch_policy_merge_types.merge_types: "merge_types/${k}" => v.id },
 { for k, v in azuredevops_branch_policy_comment_resolution.comment_resolution: "comment_resolution/${k}" => v.id },
 { for k, v in azuredevops_branch_policy_auto_reviewers.auto_reviewers: "auto_reviewers/${k}" => v.id },
 { for k, v in azuredevops_branch_policy_work_item_linking.work_item_linking: "work_item_linking/${k}" => v.id },)
}

output "project_id" {
 description = "The project ID these branch policies were created in (passthrough for composition/audit)."
 value = var.project_id
}
