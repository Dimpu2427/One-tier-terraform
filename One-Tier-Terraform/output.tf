output "public_ip" {
    description = "public Ip of the ec2 instance"
    value = aws_instance.web.public_ip

}
output "web_url" {
    value = "http://${aws_instance.web.private_ip}"
}
  



  
