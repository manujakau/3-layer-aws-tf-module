resource "aws_security_group" "this" {
  count       = var.create_sg ? 1 : 0
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "ingress" {
  count = var.create_sg ? length(var.ingress_rules) : 0

  type              = "ingress"
  security_group_id = aws_security_group.this[0].id
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
}

resource "aws_security_group_rule" "egress" {
  count = var.create_sg ? length(var.egress_rules) : 0

  type              = "egress"
  security_group_id = aws_security_group.this[0].id
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
}
