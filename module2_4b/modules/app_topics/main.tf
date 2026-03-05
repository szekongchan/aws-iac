terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.31.0"
    }
  }
}

resource "aws_sns_topic" "alert_topic" {
  name = "${var.name_prefix}-alert-sns-topic"
}

resource "aws_sns_topic" "cart_topic" {
  count = var.cart_count
  name  = "${var.name_prefix}-cart-${count.index}-sns-topic"
}
