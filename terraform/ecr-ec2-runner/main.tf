provider "aws" {
  region = "ap-south-1"
}

variable "gitlab_runner_token" {
  description = "The runner authentication token from GitLab"
  type        = string
  default     = "glrt-LwStzuJuxfjE0aBUr6U9r286MQpwOjE5Z254MQp0OjMKdTpkaG5qaRg.01.1j1h15o6q" 
}

resource "aws_ecr_repository" "my-first-ecr-repo" {
  name = "my-first-ecr-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "my-runner-role" {
  name = "gitlab-runner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role = aws_iam_role.my-runner-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "gitlab-runner-profile"
  role = aws_iam_role.my-runner-role.name
}

resource "aws_security_group" "runner_sg" {
    name = "runner-sg"
    description = "Allow SSH and outbound traffic"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "runner-talendjob" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.runner_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-instance-profile.name
  key_name = "ayush-bourai"
  user_data = <<-EOF
            user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker
    
    usermod -aG docker ubuntu

    curl -L "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" -o /usr/local/bin/gitlab-runner
    chmod +x /usr/local/bin/gitlab-runner

    useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

    rm /home/gitlab-runner/.bash_logout
    
    usermod -aG docker gitlab-runner

    gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner

    gitlab-runner register \
      --non-interactive \
      --url "https://gitlab.com/" \
      --token "${var.gitlab_runner_token}" \
      --executor "shell" \
      --description "Auto-Terraform-Runner"

    gitlab-runner start
  EOF
  
tags = {
    Name = "GitLab-Runner-Box"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.my-first-ecr-repo.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.runner-talendjob.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.runner-talendjob.public_dns
}
