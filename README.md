# terraform-aws-learning
This is a repo of my first terraform code



Tasks:
- How to use Multi region for services
- Use the dynamic iam: 
    - Canonical: ["099720109477"]
    - ubuntu value = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
- Multi region for db
- Multi account with module

- Multi providers
  - local k8s
  - eks
    policy:
        - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
        - arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
        - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
