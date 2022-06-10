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

################### Security #####################
resource "tls_private_key" "aws_keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "dev-key"
  public_key = tls_private_key.aws_keys.public_key_openssh
}

##resource "aws_key_pair" "deployer" {
##  key_name   = "temp-key"
##  public_key = ${{secrets.TEMP_KEYS}}
##}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

################## Infrastructure ###################
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name
  security_groups             = aws_security_groups.allow_tls.allow_tls

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }
  tags = {
    Name = "services"
  }
  ########################### Terraform-Ansible ###############################
  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.aws_keys.private_key_pem
    }
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${self.public_ip} --private-key ${tls_private_key.aws_keys.private_key_pem} playbook.yml"
  }

}



