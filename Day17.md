# Script for Creating EC2 Instance using AWS Cli

### Get the VPC ID

aws ec2 describe-vpcs --query "Vpcs[*].VpcId" --output text
aws ec2 describe-vpcs | jq .Vpcs[0].VpcId

### Get Subnets

SUBNET_ID=$(aws ec2 describe-subnets \
--filter Name=vpc-id,Values=$VPC_ID \
--query 'Subnets[2].SubnetId' --output text)

### Create Security Groups

```
aws ec2 create-security-group \
    --group-name created-from-cli \
    --description "SG created from CLI" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=created-from-cli}]' \
    --vpc-id $VPC_ID

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr '0.0.0.0/0'
```

### List the Security Groups

```
aws ec2 describe-security-groups --group-id sg-0a543c31605a7aec2
```

### Fetch the AMI

```
IMAGE_ID=$(aws ec2 describe-images \
 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240301" "Name=root-device-type,Values=ebs" "Name=architecture,Values=x86_64"\
 --query 'Images[0].ImageId')
```

### Create EC2 Instance

```
aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name prasanna \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-from-cli}]' 'ResourceType=volume,Tags=[{Key=Name,Value=mydisk-1}]'
```

aws ec2 describe-instance-status \
--include-all-instances \
--query 'InstanceStatuses[*].{InstanceId: InstanceId, State: InstanceState.Name}' \
--output table

### Delete EC2 Instance

```
aws ec2 terminate-instances --instance-ids i-0114bf0b7167f256a
```
