terraform {
    required_providers {
        local = {
            source = "hashicorp/local"
        }
        aws = {
            source = "hashicorp/aws"
        }
    }
}

module "servers" {
    source = "../CI"

}

resource "local_file" "hosts"{
    filename = "${path.module}/files/hosts"
    content = <<-EOF
   

    [web]
    ${module.servers.server_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_ssh_path}

    EOF
}

resource "local_file" "cfg" {
    filename = "${path.module}/files/ansible.cfg"
    content = <<-EOF
    [default]
    host_key_checking = False
    [ssh_connection]
    ssh_args = -o UserKnownHostsFile=/dev/null

    EOF

}