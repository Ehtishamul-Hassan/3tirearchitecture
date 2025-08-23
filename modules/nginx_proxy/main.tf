resource "aws_security_group" "alb" {
  name   = "${var.project}-nginx-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-nginx-alb-sg"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.project}-nginx-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project}-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_security_group" "nginx" {
  name   = "${var.project}-nginx-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-nginx-sg"
  }
}

data "aws_ami" "nginx" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project}-nginx-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOT
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y nginx1

              cat <<'CONF' > /etc/nginx/conf.d/proxy.conf
              server {
                listen 80;
                location / {
                  proxy_set_header Host $$host;
                  proxy_set_header X-Real-IP $$remote_addr;
                  proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $$scheme;
                  proxy_pass http://${aws_lb.alb.dns_name};
                }
              }
CONF

              systemctl enable nginx
              systemctl restart nginx
      EOT
  )

  vpc_security_group_ids = [aws_security_group.nginx.id]
}


resource "aws_autoscaling_group" "asg" {
  name             = "${var.project}-nginx-asg"
  max_size         = 2
  min_size         = 2
  desired_capacity = 2

  vpc_zone_identifier = var.public_subnet_ids
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-nginx"
    propagate_at_launch = true
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
