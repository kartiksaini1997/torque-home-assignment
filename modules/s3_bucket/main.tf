provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = lower("${var.name_prefix}-${random_id.suffix.hex}")
  tags = merge(var.tags, {
    "managed-by" = "terraform"
    "purpose"    = "torque-home-assignment"
  })
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
