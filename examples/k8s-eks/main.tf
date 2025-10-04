
provider "aws" {
    region = "eu-west-1"
}

module "eks_cluster" {
    source = "../../modules/services/eks-cluster"

    name = "my_eks_cluster"
    min_size = 1
    max_size = 2
    desired_size =  2
    instances_types = ["t3.small"]
}

provider "kubernetes" {
    host = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate =base64decode(
        module.eks_cluster.cluster_certificate[0].data
    )
    token = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks_cluster.cluster_name
}

module "my_webapp" {
    source = "../../modules/services/k8s-app"

    name = "my-nginx-eks"
    image = "nginx"
    container_port = 80
    replicas = 2

    #depends_on = [module.eks_cluster]

}