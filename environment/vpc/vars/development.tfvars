name             = "development"
cidr_block       = "10.0.0.0/20"
max_subnets      = 4
private_sn_count = 2
public_sn_count  = 2
public_cidrs = [
  "10.0.0.32/28",
  "10.0.0.64/28",
  "10.0.0.96/28",
  "10.0.0.128/28",
  "10.0.0.160/28",
  "10.0.0.192/28",
  "10.0.0.224/28",
  "10.0.1.0/28",
  "10.0.1.32/28",
]
private_cidrs = [
  "10.0.0.16/28",
  "10.0.0.48/28",
  "10.0.0.80/28",
  "10.0.0.112/28",
  "10.0.0.144/28",
  "10.0.0.176/28",
  "10.0.0.208/28",
  "10.0.0.240/28",
  "10.0.1.16/28",
  "10.0.1.48/28",
]