# -----------------------------------
# PUBLIC TIER [ WEB SECURITY GROUP ]
# -----------------------------------

resource "aws_security_group" "web_tier" {
  name        = "${var.project_name}-web-sg"
  description = "Public web tier"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_tier_http" {
  security_group_id = aws_security_group.web_tier.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web_tier.id
  cidr_ipv4         = "${var.my_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web_tier.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all ports and all protocols
}


# ------------------------------------------------------------
# PRIVATE TIERS [ APP SECURITY GROUP -->  DB SECURITY GROUP ]
# ------------------------------------------------------------

resource "aws_security_group" "app_tier" {
  name        = "${var.project_name}-app-sg"
  description = "Allow only Web to reach App"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_8080" {
  security_group_id            = aws_security_group.app_tier.id
  referenced_security_group_id = aws_security_group.web_tier.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id            = aws_security_group.app_tier.id
  referenced_security_group_id = aws_security_group.web_tier.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app_tier.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # equivalent to all ports and protocols
}

resource "aws_security_group" "db_tier" {
  name        = "${var.project_name}-db-sg"
  description = "Only App communicates to DB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_tier" {
  security_group_id            = aws_security_group.db_tier.id
  referenced_security_group_id = aws_security_group.app_tier.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "db_ssh" {
  security_group_id            = aws_security_group.db_tier.id
  referenced_security_group_id = aws_security_group.web_tier.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db_tier.id
  cidr_ipv4         = "0.0.0.0/0" # equivalent to all ports and protocols
  ip_protocol       = "-1"
}
