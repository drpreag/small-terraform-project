Prerequisites: custom AMI image

# Small terraform project

This terraform repository creates:

    - VPC with
        IGW
        subnets: dmz, core and db
        route tables
        NACLs
        security groups
    - Instance IAM role/profile
    - R53 .local private zone
    - Bastion / NAT EC2 instance with EIP (much cheaper then have Nat gateway)
    - Core instances within ASG in private subnet, dynamic R53 records
    - KMS key
    - RDS mysql

Note: all parameter changes should go to file: /parameters.tf .