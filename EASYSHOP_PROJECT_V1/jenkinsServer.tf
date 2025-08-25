

resource "aws_key_pair" "deployer" {
  key_name   = "my_key"
  public_key = file("my_key.pub")
}

resource "aws_instance" "jenkins_server_security" {
  ami           = "ami-0a716d3f3b16d290c"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name
  # vpc_security_group_ids = [aws_security_group.allow_jenkins_server.id]
  # subnet_id              = aws_subnet.public_subnet[0].id
  user_data = file("./jenkins_tools.sh")
  tags = {
    Name = "jenkins_server"
  }
  #   root_block_device {
  #     volume_size = 20
  #     volume_type = "gp3"
  #   }

}