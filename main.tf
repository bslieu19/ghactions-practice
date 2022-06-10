################# Networking ##################
resource "aws_vpc" "main" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.25.0/24"

  tags = {
    Name = "Lab"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.main.id
  private_ips = ["10.10.25.41"]

  tags = {
    Name = "primary_network_interface"
  }
}
