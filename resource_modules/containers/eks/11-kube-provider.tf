data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = aws_eks_cluster.eks_cluster[0].id
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster[0].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster[0].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster[0].token
}