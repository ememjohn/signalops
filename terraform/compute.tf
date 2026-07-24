# ------------------------------------------------------------------------------
# Compute
# SignalOps Monitoring Instance
# ------------------------------------------------------------------------------

resource "aws_instance" "monitor" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_pair_name
  user_data                   = file("${path.module}/scripts/user_data.sh")
  vpc_security_group_ids      = [aws_security_group.monitor_sg.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    iops                  = 3000
    throughput            = 125

    tags = merge(
      local.common_tags,
      {
        Name = "${var.instance_name}-root-volume"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.instance_name
      Role = "Monitoring"
    }
  )

  depends_on = [
    aws_internet_gateway.main
  ]
}
