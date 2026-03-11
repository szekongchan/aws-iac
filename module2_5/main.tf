resource "aws_dynamodb_table" "simple_dynamodb_table" {
  name         = "${var.project_name}-bookinventory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ISBN"
  range_key    = "Genre"

  attribute {
    name = "ISBN"
    type = "S"
  }

  attribute {
    name = "Genre"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-bookinventory"
  }
}

# Seed data into the DynamoDB table
# Note: This is a simple way to insert items, but it is not ideal for large datasets or complex data structures.
resource "aws_dynamodb_table_item" "data" {
  for_each = {
    for item in var.dynamodb_items :
    "${item.ISBN}|${item.Genre}" => item
  }
  table_name = aws_dynamodb_table.simple_dynamodb_table.name
  hash_key   = aws_dynamodb_table.simple_dynamodb_table.hash_key
  range_key  = aws_dynamodb_table.simple_dynamodb_table.range_key

  item = jsonencode({
    ISBN = {
      S = each.value.ISBN
    }
    Genre = {
      S = each.value.Genre
    }
    Title = {
      S = each.value.Title
    }
    Author = {
      S = each.value.Author
    }
    Stock = {
      N = tostring(each.value.Stock)
    }
  })
}
