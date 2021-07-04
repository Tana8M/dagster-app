################################################
// ------------ INTERNET GATEWAY------------- //
################################################


resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}


###########################################
// ------------ NAT GATEWAY------------- //
###########################################

// NAT GATEWAY WITH EIP FOR RESOURCES IN PRIVATE SUBNET
resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.ig]
}

// Each private subnet gets its own EIP
resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc   = true
}