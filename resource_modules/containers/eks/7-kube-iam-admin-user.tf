resource "aws_iam_user" "admin_user" {
  count = var.create_eks ? 1 : 0
  name          = "${var.env_name}-eks-admin01"
  path          = "/"
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_user_policy_attachment" "admin_user_attach" {
  user       = aws_iam_user.admin_user[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}