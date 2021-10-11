provider "aws"{
  profile = "default"
  region = "us-east-1"
}
resource "aws_instance" "myfirstec2"{
  ami = "ami-0b679d9e424456342"
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-b17df6ct"]
  key_name = "my-nv-key"
  tags = {
    Name = " Mydemo"
  }

}
