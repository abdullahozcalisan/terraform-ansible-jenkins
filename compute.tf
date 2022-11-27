data "aws_ami" "server_ami" {
  
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


resource "aws_instance" "ozcalisan_instance" {
  count = (length(local.azs)-2)
  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ozcalisan_sg.id]
  subnet_id = aws_subnet.ozcalisan_pub_sub[count.index].id
  key_name = aws_key_pair.ozcalisan_auth.id
  user_data = templatefile("./user_data.tpl", {new_hostname = "ozcalisan_server-${count.index+1}"})
  root_block_device {
      volume_size = var.main_vol_size
      volume_type = var.main_vol_type 
  }

  tags = {
    Name = "ozcalisan_server-${count.index+1}"
  }
  
  provisioner "local-exec" {
    
    command = "printf '\n${self.public_ip}' >> aws_hosts"
  }
  
  provisioner "local-exec" {
    when = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts" #0-9 arasındaki satırları siler /d (delete) 
  }
}

resource "aws_key_pair" "ozcalisan_auth" {
  key_name = var.key_name
  public_key = file(var.public_key_path)
}

resource "null_resource" "grafana_update" {
  count = (length(local.azs)-2)
  provisioner "remote-exec" {
    inline = ["sudo apt upgrade -y grafana && touch upgrade.log && echo 'I updated Grafana' >> upgrade.log"]
    
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("/home/ubuntu/.ssh/mtckey")
      host = aws_instance.ozcalisan_instance[0].public_ip
    }
  }
}