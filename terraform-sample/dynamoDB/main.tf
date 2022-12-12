resource "aws_dynamodb_table" "dynamodb" {
    server_side_encryption {
      enabled = false
      kms_key_arn= "arn:{redacted}"
    }
}