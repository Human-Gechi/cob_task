module "standard" {
  source = "../../standard"

  organisation = var.organisation
  project      = var.project
  environment  = var.environment
  team         = var.team
  extra_tags   = var.extra_tags
}


data "aws_ssm_parameter" "ami_amazon" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "main" {
  name               = "${module.standard.name_prefix}-${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = module.standard.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "main_profile" {
  name = "${module.standard.name_prefix}-${var.name}-ec2"
  role = aws_iam_role.main.name
  tags = module.standard.tags
}

resource "aws_security_group" "main_ec2" {
  name        = "${module.standard.name_prefix}-${var.name}-ec2"
  description = "EC2 workload ${var.name}: security group rules"
  vpc_id      = var.vpc_id

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.standard.tags, { Name = "${module.standard.name_prefix}-${var.name}-ec2" })
}

resource "aws_instance" "main_ec2" {
  count = var.instance_count

  ami           = coalesce(var.ami_id, data.aws_ssm_parameter.ami_amazon.value)
  instance_type = var.instance_type

  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids      = [aws_security_group.main_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.main_profile.id
  associate_public_ip_address = true

  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  metadata_options {
    http_tokens   = "required" # IMDSv2 only
    http_endpoint = "enabled"
  }

  tags = merge(module.standard.tags, { Name = "${module.standard.name_prefix}-${var.name}-${count.index + 1}" })
}