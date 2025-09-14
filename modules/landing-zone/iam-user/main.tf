
resource "aws_iam_user" "users" {
    for_each = toset(var.list_users)
    name = each.value
}