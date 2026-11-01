module "standard" {
  source = "../standard"

  organisation = var.organisation
  project      = var.project
  environment  = var.environment
  team         = var.team
  extra_tags   = var.extra_tags
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    module.standard.tags,
    {
      Name = "${module.standard.name_prefix}-vpc"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  for_each                = toset(local.az_zones)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0 + index(local.az_zones, each.key))
  map_public_ip_on_launch = true

  tags = merge(module.standards.tags, {
    Name = "${module.standards.name_prefix}-public-${each.key}"
    Tier = "public"
  })
}


resource "aws_subnet" "private_subnet" {
  for_each          = toset(local.az_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10 + index(local.az_zones, each.key))

  tags = merge(module.standards.tags, {
    Name = "${module.standards.name_prefix}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id


  tags = merge(module.standards.tags, {
    Name = "${module.standards.name_prefix}-igw"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(module.standards.tags, {
    Name = "${module.standards.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[local.az_zones[0]].id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  for_each = set(local.az_zones)
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(module.standards.tags, {
    Name = "${module.standards.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  for_each = set(local.az_zones)
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = merge(module.standards.tags, {
    Name = "${module.standards.name_prefix}-private-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = set(local.az_zones)
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private" {
  for_each       = set(local.az_zones)
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id

}