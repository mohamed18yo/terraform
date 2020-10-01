

variable "ami"{
    type = string

} 
# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
#security Group 
resource "aws_security_group" "sg1" {
  name        = "first-securitygroup"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh from all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}
resource "aws_security_group" "sg2" {
  name        = "second-securitygroup"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh from all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}
resource "aws_key_pair" "deployer" {
    key_name   = "defaultkey"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC006blTE37+EqfNiOfjZDmiFsvmsI+ujLrCEDdRtRrF0Y50aPciFCYXfiuDFFYrQ6+d3nyHzkY3n1rm9SRLdalt3iR1HzZqW9WyyZuHXsZzYTj/6reWZtv6AjCIs7EPhCG0jWEycLUUXV9f20fghhVZUf5ZC3cS/aPDVkSbCM2wtB2CNkwnezMJ4JJlAIwwP9nDba9S2Gvuey9Ms51rbApZdbC8EejvsYdJANasKLaolBGUo7FoCoTiTb/R1q10Jmr1bVift8f/SmHzTqZUvVm6TspMPG+cKKOCSzQiD+USGNpuzLCHRPR2yKL/WPKc7IGGGauDxdU2CHnbWILYxf9 mohamedyo@devops"

  }
#create ec2 
resource "aws_instance" "projectdevops" {
  depends_on     = [aws_security_group.sg1, aws_security_group.sg2, aws_key_pair.deployer]
  key_name = "defaultkey"
  ami            = var.ami
  instance_type  = "t3.micro"
  security_group = ["${aws_security_group.sg1.name}", "${aws_security_group.sg2.name}"]

  tags = {
    Name = "Hello"
  }
  connection {
    type ="ssh"
    user = "ec2-user"
    private_key = "${file("~/.ssh/id_rsa.pub")}"
    host = aws_instance.projectdevops.public_ip  
  }
  provisioner "remot-exec" {
    inline = [
      "echo 'hello world'",
      "sudo yum install httpd -y"
    ]
    
  }
}

resource "aws_s3_bucket" "first-s3" {
  bucket = "my-tf-test-bucket"
  acl    = "public"
  
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_object" "object" {
  bucket = "my-tf-test-bucket"
  key    = "firstbucket"
  source = "path/to/file"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("path/to/file")
}

