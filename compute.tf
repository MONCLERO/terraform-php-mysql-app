# -----------------------------------------
# EC2 INSTANCE [ AMI LOOKUP --> INSTANCE ]
# -----------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_tier.id]
  key_name               = var.key_pair_name

  user_data = templatefile("${path.module}/scripts/web_server_setup.sh", {
    app_host = aws_instance.app.private_ip
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-web-server"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.app_tier.id]
  key_name               = var.key_pair_name
  depends_on             = [aws_nat_gateway.nat]

  user_data = templatefile("${path.module}/scripts/app_server_setup.sh", {
    app_host = aws_instance.app.private_ip
    db_host     = aws_instance.db.private_ip
    db_password = var.db_password
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.db_tier.id]
  key_name               = var.key_pair_name
  depends_on             = [aws_nat_gateway.nat]

  user_data = templatefile("${path.module}/scripts/db_server_setup.sh", {
    db_password = var.db_password
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-db-server"
  }
}
