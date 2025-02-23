locals {
  configmap_roles = [
    {
      rolearn  = "${aws_iam_role.eks_nodegroup_role[0].arn}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes"
      ]
    },
    {
      rolearn  = "${aws_iam_role.eks_admin_role[0].arn}"
      username = "eks-admin" # any value as prefer(place holder name)
      groups = [
        "system:masters"
      ]
    },
    {
      rolearn  = "${aws_iam_role.eks_readonly_role[0].arn}"
      username = "eks-readonly" # any value as prefer(place holder name)
      groups = [
        "${kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding[0].subject[0].name}"
      ]
    },
    {
      rolearn  = "${aws_iam_role.eks_developer_role[0].arn}"
      username = "eks-developer" # any value as prefer(place holder name). group name specified in clusterrolebinding and in aws-auth configmap groups should be same.     
      groups = [
        "${kubernetes_role_binding_v1.eksdeveloper_rolebinding[0].subject[0].name}"
      ]
    }
  ]

  configmap_users = [
    {
      userarn  = "${aws_iam_user.admin_user[0].arn}"
      username = "${aws_iam_user.admin_user[0].name}"
      groups = [
        "system:masters"
      ]
    },
    {
      userarn  = "${aws_iam_user.basic_user[0].arn}"
      username = "${aws_iam_user.basic_user[0].name}"
      groups = [
        "system:masters"
      ]
    }
  ]
}


resource "kubernetes_config_map_v1" "aws_auth" {
  
  depends_on = [
    aws_eks_cluster.eks_cluster,
    kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding,
    kubernetes_cluster_role_binding_v1.eksdeveloper_clusterrolebinding,
    kubernetes_role_binding_v1.eksdeveloper_rolebinding
  ]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.configmap_roles)
    mapUsers = yamlencode(local.configmap_users)
  }
}