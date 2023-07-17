resource "aws_instance" "bastion" {
  ami                  = "ami-01b32aa8589df6208"
  instance_type        = "t2.nano"
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  subnet_id              = var.vpc_public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo yum install -y postgresql15.x86_64
              EOF

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp3"
    volume_size = "20"
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-bastion"
  }
}