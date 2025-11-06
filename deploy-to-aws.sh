#!/bin/bash
#########################################
# Personal Finance Goal Tracker - AWS EC2 Deployment Script
# This script automates the entire deployment process
# Usage: ./deploy-to-aws.sh
#########################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-east-1"
INSTANCE_TYPE="t3.micro"
KEY_PAIR_NAME="${1:-pfgt-key}"
YOUR_IP="14.139.125.231"  # Your public IP for SSH security
PROJECT_NAME="personal-finance-goal-tracker"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}AWS EC2 All-in-One Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Step 1: Validate AWS CLI
echo -e "${YELLOW}[1/5]${NC} Validating AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI found${NC}\n"

# Step 2: Create EC2 Key Pair (if doesn't exist)
echo -e "${YELLOW}[2/5]${NC} Checking/Creating SSH Key Pair..."
if ! aws ec2 describe-key-pairs --key-names $KEY_PAIR_NAME --region $AWS_REGION &>/dev/null; then
    echo -e "${YELLOW}Creating new key pair: $KEY_PAIR_NAME${NC}"
    aws ec2 create-key-pair \
        --key-name $KEY_PAIR_NAME \
        --region $AWS_REGION \
        --query 'KeyMaterial' \
        --output text > $KEY_PAIR_NAME.pem
    chmod 400 $KEY_PAIR_NAME.pem
    echo -e "${GREEN}✓ Key pair created: $KEY_PAIR_NAME.pem${NC}"
else
    echo -e "${GREEN}✓ Key pair already exists: $KEY_PAIR_NAME${NC}"
fi
echo ""

# Step 3: Get latest Ubuntu AMI
echo -e "${YELLOW}[3/5]${NC} Getting latest Ubuntu 24.04 LTS AMI..."
AMI_ID=$(aws ec2 describe-images \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --region $AWS_REGION \
    --output text 2>/dev/null)

if [ -z "$AMI_ID" ] || [ "$AMI_ID" = "None" ] || [ "$AMI_ID" = "null" ]; then
    echo -e "${YELLOW}⚠ Couldn't fetch Ubuntu 24.04, trying Ubuntu 22.04...${NC}"
    AMI_ID=$(aws ec2 describe-images \
        --owners 099720109477 \
        --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
        --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
        --region $AWS_REGION \
        --output text 2>/dev/null)
fi

if [ -z "$AMI_ID" ] || [ "$AMI_ID" = "None" ] || [ "$AMI_ID" = "null" ]; then
    echo -e "${RED}❌ Could not find Ubuntu AMI in region $AWS_REGION${NC}"
    echo -e "${YELLOW}Please manually select an AMI from: https://console.aws.amazon.com/ec2/v2/home?region=$AWS_REGION#Images:${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found AMI: $AMI_ID${NC}\n"

# Step 4: Create Security Group
echo -e "${YELLOW}[4/5]${NC} Creating Security Group..."
SG_NAME="pfgt-sg-$(date +%s)"
SG_ID=$(aws ec2 create-security-group \
    --group-name $SG_NAME \
    --description "Personal Finance Goal Tracker Security Group" \
    --region $AWS_REGION \
    --query 'GroupId' \
    --output text)

echo -e "${GREEN}✓ Security Group created: $SG_ID${NC}"

# Add security group rules
echo -e "${YELLOW}Adding security group rules...${NC}"

# SSH
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 22 --cidr ${YOUR_IP}/32 \
    --region $AWS_REGION &>/dev/null || true

# HTTP
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 80 --cidr 0.0.0.0/0 \
    --region $AWS_REGION &>/dev/null || true

# HTTPS
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 443 --cidr 0.0.0.0/0 \
    --region $AWS_REGION &>/dev/null || true

# API Gateway
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 8081 --cidr 0.0.0.0/0 \
    --region $AWS_REGION &>/dev/null || true

# Eureka
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 8761 --cidr 0.0.0.0/0 \
    --region $AWS_REGION &>/dev/null || true

# Grafana
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 3001 --cidr 0.0.0.0/0 \
    --region $AWS_REGION &>/dev/null || true

# Frontend
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 3000 --cidr 0.0.0.0/0 \
    --region $AWS_REGION &>/dev/null || true

echo -e "${GREEN}✓ Security group rules added${NC}\n"

# Step 5: Allocate Elastic IP
echo -e "${YELLOW}[5/5]${NC} Allocating Elastic IP..."
EIP_ALLOC=$(aws ec2 allocate-address \
    --domain vpc \
    --region $AWS_REGION \
    --query 'AllocationId' \
    --output text)

EIP=$(aws ec2 describe-addresses \
    --allocation-ids $EIP_ALLOC \
    --region $AWS_REGION \
    --query 'Addresses[0].PublicIp' \
    --output text)

echo -e "${GREEN}✓ Elastic IP allocated: $EIP${NC}\n"

# Step 6: Launch EC2 Instance
echo -e "${YELLOW}Launching EC2 Instance (t3.micro - ~$8/month)...${NC}"
echo -e "${YELLOW}Your \$140 credits will cover ~17 months of deployment${NC}\n"

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_PAIR_NAME \
    --security-group-ids $SG_ID \
    --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=30,VolumeType=gp3,DeleteOnTermination=true}' \
    --monitoring Enabled=true \
    --region $AWS_REGION \
    --query 'Instances[0].InstanceId' \
    --output text 2>&1)

echo -e "${GREEN}✓ EC2 Instance launched: $INSTANCE_ID${NC}\n"

# Associate Elastic IP
echo -e "${YELLOW}Associating Elastic IP...${NC}"
aws ec2 associate-address \
    --instance-id $INSTANCE_ID \
    --allocation-id $EIP_ALLOC \
    --region $AWS_REGION &>/dev/null

echo -e "${GREEN}✓ Elastic IP associated${NC}\n"

# Wait for instance
echo -e "${YELLOW}Waiting for instance to be running...${NC}"
aws ec2 wait instance-running \
    --instance-ids $INSTANCE_ID \
    --region $AWS_REGION

echo -e "${GREEN}✓ Instance is running${NC}\n"

# Save configuration
CONFIG_FILE="deployment-config.txt"
cat > $CONFIG_FILE << EOF
# Personal Finance Goal Tracker - Deployment Configuration
# Generated: $(date)

INSTANCE_ID=$INSTANCE_ID
ELASTIC_IP=$EIP
SECURITY_GROUP=$SG_ID
KEY_PAIR=$KEY_PAIR_NAME
REGION=$AWS_REGION
AMI_ID=$AMI_ID

# SSH Command
ssh -i $KEY_PAIR_NAME.pem ubuntu@$EIP

# Access URLs
Frontend: http://$EIP:3000
API Gateway: http://$EIP:8081
Eureka Dashboard: http://$EIP:8761
Grafana: http://$EIP:3001
Prometheus: http://$EIP:9090
EOF

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Deployment Infrastructure Ready!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${YELLOW}Configuration saved to: $CONFIG_FILE${NC}\n"

echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Wait 30 seconds for SSH to be ready"
echo -e "2. Connect to instance:"
echo -e "   ${GREEN}ssh -i $KEY_PAIR_NAME.pem ubuntu@$EIP${NC}"
echo -e "3. Run deployment commands from the guide's 'Step 3-5' section\n"

echo -e "${YELLOW}Quick Access:${NC}"
echo -e "SSH Command: ${GREEN}ssh -i $KEY_PAIR_NAME.pem ubuntu@$EIP${NC}"
echo -e "Elastic IP: ${GREEN}$EIP${NC}"
echo -e "Instance ID: ${GREEN}$INSTANCE_ID${NC}\n"

echo -e "${BLUE}To terminate all resources later, run:${NC}"
echo -e "aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $AWS_REGION"
echo -e "aws ec2 delete-security-group --group-id $SG_ID --region $AWS_REGION"
echo -e "aws ec2 release-address --allocation-id $EIP_ALLOC --region $AWS_REGION\n"