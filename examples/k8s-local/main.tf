
provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
}

module "my_app" {
    source = "../../modules/services/k8s-app"
    
    name = "dp-nginx"
    image = "nginx:latest"
    container_port = 80
    replicas = 2

}