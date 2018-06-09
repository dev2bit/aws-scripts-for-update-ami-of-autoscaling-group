#!/bin/bash
#=======================================================
# Create temporary EC2 from AMI
# Execute deploy script in temporary EC2
# Create new AMI
# Create new launch configuration
# Update and restore autoscaling group
# Clear previous data 
#=======================================================

# Config:
#=======================================================
NAME="example" # Name used for AMI, config...
AWS_BIN="~/.local/bin/aws" # PATH bin AWS
SECURITYGROUP="sg-5b06ae33 sg-5f1db437" # Security group for new AMI
KEYPAIR="keypair" # Key pair for SSH connection and AMI
PEM_FILE="~/.ssh/file.pem" # PATH pem file for key pair
INSTANCE_USER="ec2-user" # User for instance connection
INSTANCE_TYPE="m4.large" # Instance type of scaling group instances
INSTANCE_TYPE_TMP="t2.micro" # Instance type of temporal instance
AUTOSCALING_GROUP="example-scaling-group" # Name of autoscaling group for update
DEPLOY_USER="biduzz" # User for execute deploy script
DEPLOY_SCRIPT="/home/biduzz/public_html/deploy.sh" # Path for deploy script

# AWS Credentials
export AWS_ACCESS_KEY_ID=AKIAJTH6TNBWTRTIHQJA
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=eu-central-1

#=======================================================


#Src:
#=======================================================
function load {
  echo -ne '##                       (15%)\r'
  sleep $1
  echo -ne '#####                    (33%)\r'
  sleep $1
  echo -ne '#######                  (40%)\r'
  sleep $1
  echo -ne '#########                (52%)\r'
  sleep $1
  echo -ne '###########              (58%)\r'
  sleep $1
  echo -ne '#############            (66%)\r'
  sleep $1
  echo -ne '###############          (74%)\r'
  sleep $1
  echo -ne '#################        (82%)\r'
  sleep $1
  echo -ne '###################      (88%)\r'
  sleep $1
  echo -ne '#####################    (94%)\r'
  sleep $1
  echo -ne '######################   (99%)\r'
  sleep $1
  echo -ne '####################### (100%)\r'
  sleep $1
  echo -ne '\n'
}

SUBFIX=$(date +%d.%m.%y.%H.%M.%S)

echo "Get AMI ID"
AMI_DATE=$($AWS_BIN ec2 describe-images --owners 213142048088 --query 'Images[*].{date:CreationDate}' --output text | sort | tail -n1)
AMI_ID=$($AWS_BIN ec2 describe-images --owners 213142048088 --filters Name=creation-date,Values=$AMI_DATE | grep ImageId | cut -d'"' -f 4)
echo "AMI ID: $AMI_ID"
echo "Creating temporary EC2 instance"
INSTANCE_ID=$($AWS_BIN ec2 run-instances --instance-type $INSTANCE_TYPE_TMP --image-id $AMI_ID --key-name $KEYPAIR --security-group-ids $SECURITYGROUP --block-device-mappings DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true} | grep '"InstanceId"' | head -n1 | cut -d'"' -f 4)
load 25
INSTANCE_IP=$($AWS_BIN ec2 describe-instances --instance-id $INSTANCE_ID | grep '"PublicIp"' | head -n1 | cut -d'"' -f 4)
echo -ne "Temporary EC2 instance: $INSTANCE_ID ($INSTANCE_IP)                                                                        \r\n"
echo "Running deploy script in temporary EC2 instance"
echo "================================================================================"
ssh -oStrictHostKeyChecking=no -i $PEM_FILE $INSTANCE_USER@$INSTANCE_IP sudo su $DEPLOY_USER -c "$DEPLOY_SCRIPT"
echo "================================================================================"
echo "Creating new AMI"
AMI_NEW_ID=$($AWS_BIN ec2 create-image --instance-id $INSTANCE_ID --name "${NAME}.$SUBFIX" --description "AMI deploy" | grep "ImageId" | head -n1 | cut -d'"' -f 4)
load 3
echo "AMI ID: $AMI_NEW_ID"
echo "Deleting previous AMI"
$AWS_BIN ec2 deregister-image --image-id $AMI_ID
load 2
echo "Terminating temporary EC2 instance"
$AWS_BIN ec2 terminate-instances --instance-ids $INSTANCE_ID > /dev/null
load 2
echo "Creating launch configuration"
LAUNCH=$($AWS_BIN autoscaling describe-launch-configurations | grep LaunchConfigurationName | head -n1 | cut -d'"' -f 4)
$AWS_BIN autoscaling create-launch-configuration --launch-configuration-name "${NAME}.$SUBFIX" --image-id $AMI_NEW_ID --instance-type $INSTANCE_TYPE --security-groups $SECURITYGROUP --key-name $KEYPAIR > /dev/null
load 3
echo "Associating launch configuration with autoscaling group"
$AWS_BIN autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTOSCALING_GROUP --launch-configuration-name "${NAME}.$SUBFIX"
load 2
echo "Deleting previous launch configuration"
$AWS_BIN autoscaling delete-launch-configuration --launch-configuration-name $LAUNCH > /dev/null
load 1
echo "Restoring autoscaling group"
INSTANCES=$($AWS_BIN autoscaling describe-auto-scaling-groups --auto-scaling-group-name $AUTOSCALING_GROUP | grep "InstanceId" | cut -d'"' -f4)
for I in $INSTANCES; do
  echo "Terminating instance: $I"
  $AWS_BIN autoscaling terminate-instance-in-auto-scaling-group --instance-id $I --no-should-decrement-desired-capacity > /dev/null
  load 3
done
#=======================================================
