resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.name}-ecs-service"
  description = "${var.name}-ecs-service"


  tags = { Name = "${var.name}-ecs-service" }

}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service.id
  description       = "Allow all outbound"
}

resource "aws_security_group_rule" "alb" {
  count                    = var.use_alb_security_group ? 1 : 0
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.alb_security_group
  security_group_id        = aws_security_group.ecs_service.id
  description              = "Allow ALB inbound"
}

resource "aws_security_group_rule" "nlb" {
  count             = var.use_nlb_cidr_blocks ? 1 : 0
  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  cidr_blocks       = var.nlb_cidr_blocks
  security_group_id = aws_security_group.ecs_service.id
  description       = "Allow NLB inbound"
}
