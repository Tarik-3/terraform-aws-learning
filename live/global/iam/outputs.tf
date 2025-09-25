
output "all_users_module" {
    value = module.users.all_users
}

output "users_arns" {
    value = module.users.users_arn
}

output "user_upper" {
    value = <<EOF
    %{~ for key, name in var.users_names ~}
    ${upper(name)} %{if key +1 < length(var.users_names)}, %{else}. %{endif}
    %{~ endfor ~}
    EOF
}
