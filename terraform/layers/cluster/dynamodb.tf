resource "aws_dynamodb_table" "certificates" {
  name           = "certificates"
//  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 2
  hash_key       = "serial"

  attribute {
    name = "serial"
    type = "S"
  }

  attribute {
    name = "enabled"
    type = "N"
  }

//  ttl {
//    attribute_name = "TimeToExist"
//    enabled        = false
//  }

  global_secondary_index {
    name               = "idx-enabled"
    hash_key           = "enabled"
    write_capacity     = 1
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = ["common_name"]

  }

  tags = {
    Name        = "certificates-table"
    Environment = "audit"
  }

}