resource "kubernetes_service" "todowebapp_service" {
    metadata {
      name = "todowebapp-service"
    }

    spec {
      selector = {
        test = "ToDoListApp"
      }

      port {
        port = 80
        target_port = 80
      }

      type = "LoadBalancer"
    }
}