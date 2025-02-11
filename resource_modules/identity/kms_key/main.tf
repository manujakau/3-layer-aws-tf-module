resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  tags                    = var.tags
  policy                  = var.policy
  enable_key_rotation     = var.enable_key_rotation

}

resource "aws_kms_alias" "this" {
  name          = var.name
  target_key_id = aws_kms_key.this.key_id
}