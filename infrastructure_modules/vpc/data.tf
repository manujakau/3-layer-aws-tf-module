locals {
  ## VPC ##  
  public_subnet_tags = {
    "Tier" = "public",
    "kubernetes.io/role/elb" = 1,
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  # need tag for internal-elb to be able to create ELB
  private_subnet_tags = {
    "Tier" = "private",
    "kubernetes.io/role/internal-elb" = 1,
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  ## Public SG ##
  public_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-public"
  public_security_group_description = "Security group for public subnets"
  public_security_group_tags = merge(
    var.tags,
    tomap({
      "Name" = local.public_security_group_name
    }),
    tomap({
      "Tier" = "public"
    })
  )

  ## Private SG ##
  private_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-private"
  private_security_group_description = "Security group for private subnets"
  private_security_group_tags = merge(
    var.tags,
    tomap({
      "Name" = local.private_security_group_name
    }),
    tomap({
      "Tier" = "private"
    }),
  )
}