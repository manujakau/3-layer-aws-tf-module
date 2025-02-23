resource "kubernetes_namespace_v1" "k8s_dev" {
  count = var.create_eks ? 1 : 0
  metadata {
    name = "dev"
  }
}