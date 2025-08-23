provider "aws" {
  region = var.region
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}


resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = "sg-0aac5477659561e39" # Existing SG ID
  source_security_group_id = aws_security_group.alb_sg.id
}




# Application Load Balancer
resource "aws_lb" "springboot_alb" {
  name               = "springboot-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "springboot-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "springboot_tg" {
  name     = "springboot-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "springboot-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "springboot_listener" {
  load_balancer_arn = aws_lb.springboot_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot_tg.arn
  }
}

# Target group attachements

resource "aws_lb_target_group_attachment" "spring_attachment" {
  target_group_arn = aws_lb_target_group.springboot_tg.arn
  target_id        = "i-0706b849e688056c0" # Replace with your EC2 instance ID
  port             = 8080
}
