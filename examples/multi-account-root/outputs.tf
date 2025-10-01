output "parent_account_id" {
    value = data.aws_caller_identity.parent.account_id
}

output "child_account_id" {
    value = data.aws_caller_identity.child.account_id
}
