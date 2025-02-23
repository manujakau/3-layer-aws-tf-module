data "aws_partition" "current" {} # current AWS partition in which Terraform is working

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.create_eks ? 1 : 0
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = aws_eks_cluster.eks_cluster[0].identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = "${var.cluster_name}-eks-irsa"
    },
    var.tags
  )
}


locals {
  aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider[0].arn}"), 1)
}