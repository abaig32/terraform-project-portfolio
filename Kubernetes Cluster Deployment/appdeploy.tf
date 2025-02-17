resource "kubernetes_deployment" "todowebapp" {

  depends_on = [kubernetes_service.todowebapp_service]

  metadata {
    name = "webapp"
    labels = {
      test = "ToDoListApp"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "ToDoListApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "ToDoListApp"
        }
      }

      spec {
        container {
          image = "abaig32/todo-app"
          name  = "todo-app-image"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}


