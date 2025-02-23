resource "aws_iam_group" "eksdeveloper_iam_group" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eksdeveloper"
  path  = "/"
}

resource "aws_iam_group_policy" "eksdeveloper_iam_group_assumerole_policy" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eksdeveloper-group-policy"
  group = aws_iam_group.eksdeveloper_iam_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid      = "AllowAssumeOrganizationAccountRole"
        Resource = "${aws_iam_role.eks_developer_role[0].arn}"
      },
    ]
  })
}

resource "aws_iam_user" "eksdeveloper_user" {
  count         = var.create_eks ? 1 : 0
  name          = "${var.cluster_name}-eksdeveloper01"
  path          = "/"
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_group_membership" "eksdeveloper" {
  count = var.create_eks ? 1 : 0
  name  = "${var.cluster_name}-eksdeveloper-group-membership"
  users = [
    aws_iam_user.eksdeveloper_user[0].name
  ]
  group = aws_iam_group.eksdeveloper_iam_group[0].name
}