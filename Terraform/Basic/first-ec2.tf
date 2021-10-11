provider "aws"{
  profile = "default"
  region = "us-east-1"
}
resource "aws_instance" "myfirstec2"{
  ami = "ami-0b679d9e424a41e40"
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-b17df5c6"]
  key_name = "jigi-nv-key"
  tags = {
    Name = "Scoute Suite demo"
  }

}
