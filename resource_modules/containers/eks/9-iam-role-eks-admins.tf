resource "aws_iam_role" "eks_admin_role" {
  count = var.create_eks ? 1 : 0
  name = "${var.cluster_name}-eks-admin-role"

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
    tag-key = "${var.cluster_name}-eks-admin-role"
  }
}

resource "aws_iam_role_policy" "eks_admin_policy" {
  name = "eks-full-access-policy"
  role = aws_iam_role.eks_admin_role[0].id

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