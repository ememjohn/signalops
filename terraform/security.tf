# ------------------------------------------------------------------------------
# Security Group
# SignalOps Production Security
# ------------------------------------------------------------------------------

resource "aws_security_group" "monitor_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for SignalOps monitoring services"
  vpc_id      = aws_vpc.signalops.id

  ingress {
    description = "SSH Administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Grafana Dashboard"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
  description = "Alertmanager"
  from_port   = 9093
  to_port     = 9093
  protocol    = "tcp"
  cidr_blocks = [var.admin_cidr]
}

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.instance_name}-sg"
    }
  )
}
