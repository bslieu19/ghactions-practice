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

################### Security #####################
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

resource "tls_private_key" "aws_keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.aws_keys.public_key_openssh
}

##resource "aws_key_pair" "deployer" {
##  key_name   = "temp-key"
##  public_key = ${{secrets.TEMP_KEYS}}
##}


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
  tags = {
    Name = "HelloWorld"
  }
  ########################### Terraform-Ansible ###############################
  provisioner "local-exec" { command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u {var.user} -i ${self.public_ip} --private-key ${tls_private_key.aws_keys.private_key_pem} playbook.yml" }
}



