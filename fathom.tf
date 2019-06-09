resource "aws_lb" "fathom" {
  name = "fathom"

  subnets = [
    "${aws_subnet.subnet_1a.id}",
    "${aws_subnet.subnet_1b.id}",
  ]

  security_groups = ["${aws_security_group.http_ingress.id}"]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = "${aws_lb.fathom.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.fathom.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "fathom" {
  name     = "fathom-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_launch_configuration" "fathom" {
  name_prefix     = "fathom-launch-configuration"
  image_id        = "ami-0913ff878b4245c00"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.steven.key_name}"
  security_groups = ["${aws_security_group.http_ingress.id}", "${aws_security_group.ssh_ingress.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "fathom" {
  name = "fathom-asg"

  min_size = 1
  max_size = 1

  launch_configuration = "${aws_launch_configuration.fathom.id}"
  target_group_arns    = ["${aws_lb_target_group.fathom.arn}"]

  vpc_zone_identifier = [
    "${aws_subnet.subnet_1a.id}",
    "${aws_subnet.subnet_1b.id}",
  ]
}
