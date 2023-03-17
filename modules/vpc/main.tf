data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

locals {
  eks_tags = {
    Cluster = var.name
  }
}

#####################################
############## VPC ##################
#####################################

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${title(var.name)}"
    Cluster = var.name
  }
}

#####################################
######### Public Subnets ############
#####################################

resource "aws_subnet" "public_subnet" {
  count = var.public_sn_count

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    Name    = "${var.name}/public_subnet_${count.index}"
    Cluster = var.name
    },
    // https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
    {
      "kubernetes.io/cluster/${var.name}" = "shared"
      "kubernetes.io/role/elb"            = "1"
  })

}

#####################################
######### Private Subnets ###########
#####################################

resource "aws_subnet" "private_subnet" {
  count = var.private_sn_count

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = merge({
    Name    = "${var.name}/private_subnet_${count.index}"
    Cluster = var.name
    },
    // https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
    {
      "kubernetes.io/cluster/${var.name}" = "shared"
      "kubernetes.io/role/internal-elb"   = "1"
  })

}

#####################################
######## Internet Gateway ###########
#####################################

resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.name}/internet_gateway"
  }, local.eks_tags)
}

#########################################
######### Public Route Table ############
#########################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${aws_vpc.vpc.id}/public_route_table"
  }, local.eks_tags)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet.id
}

resource "aws_route_table_association" "public" {
  count = var.public_sn_count

  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

#########################################
############# Nat Gateway ###############
#########################################

resource "aws_eip" "nat" {
  count = var.private_sn_count

  vpc = true
  tags = merge(
    {
      Name = "${var.name}/nat_ip_${count.index}"
    },
    local.eks_tags
  )
}

resource "aws_nat_gateway" "nat" {
  count = var.private_sn_count

  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.public_subnet.*.id[count.index]

  tags = merge(
    {
      Name = "${var.name}/nat_gateway_${count.index}"
    },
    local.eks_tags
  )
}
