output "cart_topic_arns" {
  value = aws_sns_topic.cart_topic[*].arn
}
