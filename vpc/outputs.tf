output "vpc-id" {
  value = aws_vpc.vpc.id
}

output "vpc-cidr-block" {
  value = aws_vpc.vpc.cidr_block
}

output "public-subnet-1-id" {
  value = aws_subnet.public-subnet-1.id
}

output "public-subnet-2-id" {
  value = aws_subnet.public-subnet-2.id
}

output "public-subnet-3-id" {
  value = aws_subnet.public-subnet-3.id
}

output "private-subnet-1-id" {
  value = aws_subnet.private-subnet-1.id
}

output "private-subnet-2-id" {
  value = aws_subnet.private-subnet-2.id
}

output "private-subnet-3-id" {
  value = aws_subnet.private-subnet-3.id
}

output "private-subnets" {
  value = tolist([aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id])
}

output "public-subnets" {
  value = tolist([aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id, aws_subnet.public-subnet-3.id])
}
