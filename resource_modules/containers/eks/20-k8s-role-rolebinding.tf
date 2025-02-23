resource "kubernetes_role_v1" "eksdeveloper_role" {
  count = var.create_eks ? 1 : 0
  metadata {
    name      = "${var.cluster_name}-eksdeveloper-role"
    namespace = "dev"
  }

  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding_v1" "eksdeveloper_rolebinding" {
  count = var.create_eks ? 1 : 0
  metadata {
    name      = "${var.cluster_name}-eksdeveloper-rolebinding"
    namespace = "dev"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.eksdeveloper_role[0].metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "eks-developer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}