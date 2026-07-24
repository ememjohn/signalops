# ==============================================================================
# Global / Environment Variables
# ==============================================================================

variable "aws_region" {
  description = "Target AWS region for resource deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-(?:gov-)?(?:iso-)?(?:[a-z]+-)?\\d{1}$", var.aws_region))
    error_message = "Must be a valid AWS region identifier (e.g., us-east-1, eu-west-1)."
  }
}

variable "environment" {
  description = "Deployment lifecycle environment"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Standard prefix applied to resources and billing tags"
  type        = string
  default     = "signalops"
}

# ==============================================================================
# Compute Instance Parameters
# ==============================================================================

variable "instance_name" {
  description = "Logical identifier assigned to the monitor EC2 instance tag"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.instance_name))
    error_message = "Instance name must be kebab-case lowercase alphanumeric characters and hyphens."
  }
}

variable "instance_type" {
  description = "EC2 compute instance profile specification"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must follow valid EC2 sizing nomenclature (e.g., t3.micro, c6i.large)."
  }
}

# ==============================================================================
# SSH Key Pair
# ==============================================================================

variable "key_pair_name" {
  description = "Existing AWS EC2 Key Pair name used for SSH access"
  type        = string

  validation {
    condition     = length(trimspace(var.key_pair_name)) > 0
    error_message = "key_pair_name cannot be empty."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the SignalOps VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the SignalOps public subnet."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "The public subnet CIDR block must be a valid IPv4 CIDR."
  }
}

variable "admin_cidr" {
  description = "CIDR block allowed to access SignalOps administrative services."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 CIDR block."
  }
}
