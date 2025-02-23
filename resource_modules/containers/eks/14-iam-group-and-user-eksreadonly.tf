resource "aws_iam_group" "eksreadonly_iam_group" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eksreadonly"
  path  = "/"
}

resource "aws_iam_group_policy" "eksreadonly_iam_group_assumerole_policy" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eksreadonly-group-policy"
  group = aws_iam_group.eksreadonly_iam_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid      = "AllowAssumeOrganizationAccountRole"
        Resource = "${aws_iam_role.eks_readonly_role[0].arn}"
      },
    ]
  })
}

resource "aws_iam_user" "eksreadonly_user" {
  count         = var.create_eks ? 1 : 0
  name          = "${var.cluster_name}-eksreadonly01"
  path          = "/"
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_group_membership" "eksreadonly" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eksreadonly-group-membership"
  users = [
    aws_iam_user.eksreadonly_user[0].name
  ]
  group = aws_iam_group.eksreadonly_iam_group[0].name
}