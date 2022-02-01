#-------------
# LOOP EXAMPLES
#-------------

#-------------
# for_each - The reason why for_each does not work on list(string) is because a list can contain duplicate values but if you are using set(string) or map(string) then it does not support duplicate values.
#-------------
variable "user_names_set" {
  description = "IAM usernames with set type"
  type        = set(string)
  default     = ["Niki", "Joro", "Stefi"]
} 

resource "aws_iam_user" "example" {
  for_each = var.user_names
  name  = each.value
}

#-------------
# count - This is simply iterate over the list(string)
#-------------
variable "user_names" {
  description = "IAM usernames in a list"
  type        = list(string)
  default     = ["Niki", "Joro", "Stefi"]
}

resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

data "aws_iam_policy_document" "ec2_read_only" {
  statement {
    effect    =  "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_read_only" {
  name   = "ec2-read-only"
  policy = data.aws_iam_policy_document.ec2_read_only.json
}

resource "aws_iam_user_policy_attachment" "ec2_access" {
  count      = length(var.user_names)
  user       = aws_iam_user.example.*.name[count.index]
  policy_arn = aws_iam_policy.ec2_read_only.arn
}

output "user_arns" {
  value = [aws_iam_user.example.*.arn]
}

#-------------
# for_loop - This is simply iterate over the list(string)
#-------------
variable "iam_users" {
  description = "map"
  type        = map(string)
  default     = {
    user1      = "normal user"
    user2  = "admin user"
    user3 = "root user"
  }
}

output "user_with_roles" {
  value = [for name, role in var.iam_users : "${name} is the ${role}"]
}

# For list
# {for <ITEM> in <LIST> : <OUTPUT_KEY> => <OUTPUT_VALUE>}

# For map
# {for <KEY>, <VALUE> in <MAP> : <OUTPUT_KEY> => <OUTPUT_VALUE>} 

#-------------
# Dynamic block
#-------------
resource "aws_security_group" "main" {
   name   = "resource_without_dynamic_block"
   vpc_id = data.aws_vpc.main.id

   ingress {
      description = "ingress_rule_1"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   
   ingress {
      description = "ingress_rule_2"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "AWS security group non-dynamic block"
   }
}

# --------------------------

locals {
   ingress_rules = [{
      port        = 443
      description = "Ingress rules for port 443"
   },
   {
      port        = 80
      description = "Ingree rules for port 80"
   }]
}

resource "aws_security_group" "main" {
   name   = "resource_with_dynamic_block"
   vpc_id = data.aws_vpc.main.id

   dynamic "ingress" {
      for_each = local.ingress_rules

      content {
         description = ingress.value.description
         from_port   = ingress.value.port
         to_port     = ingress.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
      Name = "AWS security group dynamic block"
   }
}