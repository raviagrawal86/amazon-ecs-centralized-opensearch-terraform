locals {
  tags = var.tags
  name = "${var.prefix}-es"

  # if region is not passed, we assume the current one
  es_region                 = coalesce(var.aws_region, data.aws_region.current.name)
  es_zone_awareness_enabled = length(data.aws_availability_zones.available.names) > 1
}
