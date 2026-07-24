# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

# Fetch the latest Amazon Linux 2023 AMI via AWS SSM Parameter Store
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
