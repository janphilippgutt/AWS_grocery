

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5000 # Lets the ALB accept traffic on port 5000 from the internet
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "web-sg"
  }
}


resource "aws_lb" "app_lb" {
  name               = "lb-grocery-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.public_subnets
    # because the load-balancer lives in the public subnet and serves ec2 instances in private subnets

  tags = {
    Name = "grocery-app-lb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 5000 # Target group forwards to port 5000 on EC2
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  #  ensure only healthy EC2s receive traffic
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-tg"
  }
}

# Register the EC2s with the Target Group: (! loop over all ec2 instances applied?)

resource "aws_lb_target_group_attachment" "web" {
  for_each = var.instance_map

  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = each.value
  port             = 5000
}

# Listener forwards traffic to our target group (which contains our EC2s)

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Include a listener on port 80 that forwards to existing target group on port 5000
# This solved an issue of the app running inside the container, but ALB unable to listen
resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
