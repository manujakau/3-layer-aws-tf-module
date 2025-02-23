resource "kubernetes_cluster_role_v1" "eksreadonly_clusterrole" {
  count = var.create_eks ? 1 : 0
  metadata {
    name = "${var.cluster_name}-eksreadonly-clusterrole"
  }
  rule {
    api_groups = [""] # From core APIs
    resources  = ["nodes", "namespaces", "pods", "events", "services"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "eksreadonly_clusterrolebinding" {
  count = var.create_eks ? 1 : 0
  metadata {
    name = "${var.cluster_name}-eksreadonly-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eksreadonly_clusterrole[0].metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "eks-readonly-group"
    api_group = "rbac.authorization.k8s.io"
  }
}