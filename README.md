# Terraform-code-2-aws_account
Terraform code for 2 aws account infrastructure where vpc, S3 and Instance created 

1. take 2 AWS accounts setup within script 
2. create vpc with 2 public and 2 private subnets on basis of availability zones on aws account A.
3. Create an one ec2 instance in account A with taking vpc subnets from above created vpc within ubuntu OS with security group and create ssh-key file with your local-systems public-key and output the private_key file.
4. Create an s3 bucket in account B with encryption enable.

Note: Create an dev.tfvars file with mention Name of resource and CIDR for VPC
