terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "terraform-luis"

    workspaces {
      name = "challenge-terraform"
    }
  }
}

## Error que obtengo cuando corre este bloque es el mismo que este
## https://github.com/GoogleCloudPlatform/terraformer/issues/1428
## Error fue resuelto mediante la utilizacion de las variables de ambiente en TF Cloud como
## AWS_ACCESS_KEY en vez de TF_AWS_ACCESS_KEY

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami                    = "ami-026b57f3c383c2eec"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "test-value" {
  value = "Instancia de AWS completada de manera correcta"
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
