name             = "production"
cidr_block       = "10.0.0.0/20"
max_subnets      = 4
private_sn_count = 2
public_sn_count  = 2
public_cidrs     = [for i in range(2, 256, 2) : cidrsubnet("10.0.0.0/20", 8, i)]
private_cidrs    = [for i in range(1, 256, 2) : cidrsubnet("10.0.0.0/20", 8, i)]
