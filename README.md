<p align="center">
<a href="https://www.dev2bit.com">
  <img width="200" alt="dev2bit"  src="https://raw.githubusercontent.com/fbohorquez/sql-charts-dashboard/master/resources/logo.png"/>
</a>
</p>

# aws-scripts-for-update-ami-of-autoscaling-group
AWS Scripts for update AMI of Autoscaling Group
# Requirements
* [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [Access Keys for IAM Users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey_CLIAPI)
# Scripts
Two bash scripts
## aws.as.ami_admin.sh
* Create temporary EC2 from AMI
* Open SSH terminal
* Create new AMI
* Create new launch configuration
* Update and restore autoscaling group
* Clear previous data 

## aws.as.ami_deploy.sh
* Create temporary EC2 from AMI
* Execute deploy script in temporary EC2
* Create new AMI
* Create new launch configuration
* Update and restore autoscaling group
* Clear previous data 

# Configure scripts
Scripts define vars you must edit:
* NAME: Name used for AMI, config...
* AWS_BIN: PATH bin AWS
* SECURITYGROUP: Security group for new AMI
* KEYPAIR: Key pair for SSH connection and AMI
* PEM_FILE: PATH pem file for key pair
* INSTANCE_USER: User for instance connection
* INSTANCE_TYPE: Instance type of scaling group instances
* INSTANCE_TYPE_TMP: Instance type of temporal instance
* AUTOSCALING_GROUP: Name of autoscaling group for update
* DEPLOY_USER: User for execute deploy script
* DEPLOY_SCRIPT: Path for deploy script
* AWS_ACCESS_KEY_ID: Access key AWS Credentials 
* AWS_SECRET_ACCESS_KEY: Secrect access key AWS Credentials
* AWS_DEFAULT_REGION: deafult AWS region for work

## Autor

Francisco Javier Bohórquez Ogalla

Developed with ♥ by [dev2bit](https://www.dev2bit.com)
