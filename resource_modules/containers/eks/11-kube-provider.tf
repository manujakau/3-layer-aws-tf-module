data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = aws_eks_cluster.eks_cluster[0].id
}

provider "kubernetes" {
  host                   = length(aws_eks_cluster.eks_cluster) > 0 ? aws_eks_cluster.eks_cluster[0].endpoint : null
  cluster_ca_certificate = length(aws_eks_cluster.eks_cluster) > 0 ? base64decode(aws_eks_cluster.eks_cluster[0].certificate_authority[0].data) : ""
  token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
}