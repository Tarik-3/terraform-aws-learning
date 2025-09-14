output "all_users" {
    description = "All the users that you create"
    value = values(aws_iam_user.users)
}

output "users_arn" {
    description = "Users' arns"
    value = values(aws_iam_user.users)[*].arn
}