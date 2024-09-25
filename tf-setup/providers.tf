provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"

  default_tags {
    tags = local.tags
  }
}
