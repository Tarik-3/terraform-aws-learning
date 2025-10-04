locals {
    status = kubernetes_service.app.status
}

output "app_url" {
    value = try(
        "http://${local.status[0].load_balancer[0].ingress[0].hostname}",
        "(Error in the url)"
    )
}