resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.env}-IGW"
  }

}