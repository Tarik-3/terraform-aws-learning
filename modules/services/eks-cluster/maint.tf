
resource "aws_iam_role"  "cluster" {
    name = "${var.name}-cluster-role"

    assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

#Allow EKS to assume the IAM Role
data "aws_iam_policy_document" "cluster_assume_role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
    }
}

#Attach permission to IAM role
resource "aws_iam_role_policy_attachment" "eks_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.cluster.name
}

data "aws_vpc" "default" {
    default  = true
}

data "aws_subnets" "sbn" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_eks_cluster" "cluster" {
    name = var.name
    role_arn = aws_iam_role.cluster.arn
    version ="1.29"

    vpc_config {
        subnet_ids = data.aws_subnets.sbn.ids
    }
}


# Workers nodes


resource "aws_iam_role" "node_group" {
    name = "${var.name}-node-group-role"
    assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

data "aws_iam_policy_document" "node_assume_role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }

    }
}

resource "aws_iam_role_policy_attachment" "ec2_cr_read_only" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    policy_arn =  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.node_group.name
}

resource "aws_eks_node_group" "nodes" {
    cluster_name = aws_eks_cluster.cluster.name
    node_group_name = var.name
    subnet_ids = data.aws_subnets.sbn.ids
    instance_types = var.instances_types

    node_role_arn = aws_iam_role.node_group.arn

    scaling_config {
        min_size = var.min_size
        max_size = var.max_size
        desired_size = var.desired_size
    }
}