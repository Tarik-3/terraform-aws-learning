output "s3-bucket-name" {
    description = "The s3 name:"
    value = aws_s3_bucket.s3.arn
}

output "dynamodb-name" {
    description = "The name of dynamodb"
    value = aws_dynamodb_table.s3-db.name
}