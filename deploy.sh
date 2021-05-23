#!/bin/bash
aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name IAM --template-file iam/iam.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name S3 --template-file s3/s3.yaml

aws s3 sync s3://ptt-alertor-3-bucket s3://ptt-alertor-2020-bucket

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name VPC --template-file vpc/vpc.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name ECR --template-file ecr/ecr.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name ECS-Cluster --template-file ecs-cluster/ecs-cluster.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name ECS-Hosts --template-file ecs-hosts/ecs-hosts.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name Redis --template-file redis/redis.json

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name ACM --template-file acm/acm.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name ECS-Service --template-file ecs-service/ecs-service.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name SNS --template-file sns/sns.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name CloudWatch --template-file cloudwatch/cloudwatch.yaml

aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name Elasticsearch --template-file elasticsearch/elasticsearch.yaml
