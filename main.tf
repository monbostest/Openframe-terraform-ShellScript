resource "aws_security_group" "openframe" {
  name        = "openframe"
  description = "This will be used for Openframe only"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["202.54.0.0/16"]
  }
    vpc_id = "vpc-052e07b76f98ec8d2"
  tags = {
    Name = "Permander_Openframe"
  }
}








resource "aws_instance" "myinstance" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key}"
  subnet_id = "${var.subnet}"
  security_groups =  ["${aws_security_group.openframe.id}" ]
  user_data = "${file("./openframe_prerequisite.sh")}"
#  region = "${var.region}"
  tags = {
    Name = "Permander"
    POC_Name = "mainframe"
    Costcenter = "CCOE"
    }
}
#output "instance_ip_addr" {
#}
output "instance_ips" {
  value = ["${aws_instance.myinstance.*.public_ip}"]
}
output "instance_Prips" {
  value = ["${aws_instance.myinstance.*.private_ip}"]
}
