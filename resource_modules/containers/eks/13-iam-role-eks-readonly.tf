resource "aws_iam_role" "eks_readonly_role" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eks-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.cluster_name}-eks-readonly-role"
  }
}

resource "aws_iam_role_policy" "eks_readonly_policy" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eks-full-access-policy"
  role  = aws_iam_role.eks_readonly_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "ssm:GetParameter",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:ListUpdates",
          "eks:ListFargateProfiles",
          "eks:ListIdentityProviderConfigs",
          "eks:ListAddons",
          "eks:DescribeAddonVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}