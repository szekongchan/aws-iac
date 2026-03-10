resource "aws_dynamodb_table" "simple_dynamodb_table" {
  name         = "${var.project_name}-dynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ISDN"
  range_key    = "Genre"

  attribute {
    name = "ISDN"
    type = "S"
  }

  attribute {
    name = "Genre"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-dynamodb"
  }
}
