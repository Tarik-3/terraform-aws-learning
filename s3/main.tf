
provider "aws" {
    region = "eu-west-3"

}

terraform {
    backend "s3" {
        bucket = "my-s3-tarik"
        key = "global/s3/terraform.tfstate"


        use_lockfile = true
        region = "eu-west-3"
        encrypt = true

    }
}

resource "aws_s3_bucket" "s3" {
    bucket = "my-s3-tarik"

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "s3-vers"{

    bucket = aws_s3_bucket.s3.id

    versioning_configuration {
        status  = "Enabled"
    }

}


resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encrypt" {
    bucket = aws_s3_bucket.s3.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_dynamodb_table" "s3-db" {

    name = "iac-s3-dynamodb"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}

output "s3-bucket-name" {
    description = "The s3 name:"
    value = aws_s3_bucket.s3.arn
}

output "dynamodb-name" {
    description = "The name of dynamodb"
    value = aws_dynamodb_table.s3-db.name
}