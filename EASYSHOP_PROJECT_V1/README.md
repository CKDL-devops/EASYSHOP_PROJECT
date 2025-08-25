# EASYSHOP_PROJECT
This is personnal project where i want to share some best devops practices in production environment with a microservice application deploy on EKS.
stage 1 :
THE first think to day is to set up a jenkins server on aws as we will use AWS and don't forget to handle security group inbound rules to allow ssh and jenkins 8080 port, then after it you can refer to this repo.
you have in this directory all the required aws resources to set up a VPC  with all the subsidiaries resources:
- the vpc name,
- one internet gateway,
- one nat gateway,
- 02 private subnets for 02 AZs,
- 02 public subnets for 02 AZs,
- 01  public route table with associations and a default route set to IGW,
- 01 private route table with assaciations and a default route set to the NAT gateway
- set a webhook on this github directory to automatically trigger a pipline in jenkins after a push request,
- we set the required authentications between our jenkins server and github also with aws.