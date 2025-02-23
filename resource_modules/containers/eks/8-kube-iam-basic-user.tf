resource "aws_iam_user" "basic_user" {
  count         = var.create_eks ? 1 : 0
  name          = "${var.env_name}-eks-admin02"
  path          = "/"
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_user_policy" "basic_user_eks_policy" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eks-full-access-policy"
  user  = aws_iam_user.basic_user[0].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
