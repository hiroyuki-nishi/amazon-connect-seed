output "vpc_id" {
  value = aws_vpc.prefix_xxx_dev.id
}

output "vpc_public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "vpc_private_subnet_ids" {
  value = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1c.id]
}
