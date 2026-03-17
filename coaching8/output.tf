output "dynamodb_table_name" {
  value = try(aws_dynamodb_table.bookinventory[0].name, null)
}
