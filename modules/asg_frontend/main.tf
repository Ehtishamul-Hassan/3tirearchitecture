resource "aws_security_group" "sg" {
  name   = "${var.project}-frontend-sg"
  vpc_id = var.vpc_id

  # Inbound only from ALB security group will be added in root by referencing this SG (done via ALB allowed_sg_ids)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-frontend-sg"
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project}-frontend-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOT
    #!/bin/bash
    # TODO: start your frontend service
  EOT
  )

  vpc_security_group_ids = [aws_security_group.sg.id]
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project}-frontend-asg"
  max_size            = 2
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-frontend"
    propagate_at_launch = true
  }
}

output "sg_id" {
  value = aws_security_group.sg.id
}
