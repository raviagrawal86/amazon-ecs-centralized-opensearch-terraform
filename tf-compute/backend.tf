terraform {
  backend "s3" {
    bucket         = "bayer-veg-ecs-terraform-state-109972344243"
    key            = "ecs/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bayer-veg-ecs-terraform-state-lock"
  }
}
