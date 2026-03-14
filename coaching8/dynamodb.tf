resource "aws_dynamodb_table" "bookinventory" {
  count        = var.enable_dynamodb ? 1 : 0
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
  for_each = var.enable_dynamodb ? {
    for item in var.dynamodb_items :
    "${item.ISBN}|${item.Genre}" => item
  } : {}
  table_name = aws_dynamodb_table.bookinventory[0].name
  hash_key   = aws_dynamodb_table.bookinventory[0].hash_key
  range_key  = aws_dynamodb_table.bookinventory[0].range_key

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
