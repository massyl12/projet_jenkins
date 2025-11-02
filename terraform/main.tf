##############################################
# 🚀 Configuration Terraform + AWS
##############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-3" # 🌍 Paris
}

##############################################
# 🔑 Utiliser ta clé publique existante
##############################################

resource "aws_key_pair" "jenkins_key" {
  key_name   = "projet_jenkins_key"
  public_key = file("~/Documents/projet_jenkins/projet_jenkins.pub")
}

##############################################
# 💻 Environnements : Review, Staging, Prod
##############################################

resource "aws_instance" "review" {
  ami           = "ami-00c71bd4d220aa22a"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "webapp-review"
    Env  = "review"
  }
}

resource "aws_instance" "staging" {
  ami           = "ami-00c71bd4d220aa22a"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "webapp-staging"
    Env  = "staging"
  }
}

resource "aws_instance" "prod" {
  ami           = "ami-00c71bd4d220aa22a"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "webapp-prod"
    Env  = "prod"
  }
}

#####################################
# 🔒 Règles de sécurité
##############################################

resource "aws_security_group" "web_sg" {
  name        = "webapp-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
##############################################
# 🌐 Afficher les IPs des 3 serveurs
##############################################

output "review_ip" {
  value = aws_instance.review.public_ip
}

output "staging_ip" {
  value = aws_instance.staging.public_ip
}

output "prod_ip" {
  value = aws_instance.prod.public_ip
}
#########
