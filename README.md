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
    - Bastion EC2 instance with EIP
    - Core instances within ASG in private subnet
    - R53 .local zone, with bastion instance record, and dynamic records for core ASG
    - 

Note: all parameter changes should go to file: /parameters.tf .