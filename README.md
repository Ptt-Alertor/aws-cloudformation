# Ptt Alertor AWS Cloudformation

![main workflow](https://github.com/Ptt-Alertor/aws-cloudformation/actions/workflows/main.yml/badge.svg)

## Architecture

![architecture](ptt_alertor_architecture.png)
<https://app.cloudcraft.co/view/7314db72-b1f6-4f49-b773-c3a11d4ed92b?key=tulQtXdlKJ2FIbHoaHqTzQ>

## [Command](http://docs.aws.amazon.com/cli/latest/reference/cloudformation/index.html#cli-aws-cloudformation)

* Validate Stack

  ```bash
  aws cloudformation validate-template --template-body file://./s3/s3.yaml
  ```

* Deploy Stack

  ```bash
  aws cloudformation deploy --capabilities CAPABILITY_IAM --stack-name S3 --template-file s3/s3.yaml
  ```

## Steps

* [x] Create AWS Account by new Email
* [x] Create IAM User: *deploy* with Administrator Access Permission
* [x] Update AWS Credential in Github Organization Secrets
* [x] Update Stack
  * [x] s3
    * [x] new s3 bucket name
    * [x] add bucket policy to old bucket
  * [x] redis
    * [x] Update engine version
  * [x] acm
    * [x] Certificate Approval
  * [x] cloudwatch
    * [x] copy dashboard source from console to `cloudwatch.yml`
  * [x] opensearch
    * [x] migrate opensearch and dashboard setting
    * [x] Update opensearch version
* [x] tag `initial` to initial environment
* [x] migrate ptt-alertor
  * [x] service-ptt-alertor
    * [x] push image to ECR
  * [x] stop service in former account
    * [x] update ECS Service's Number of tasks to 0
    * [x] docker stop container
  * [x] dynamodb
    * [x] create DynamoDBCrossAccessRole in old account and add new account in trust entity
    * [x] use glue job to migrate db from old account to new account
  * [x] migrate redis db
  * [x] DNS change
  * [x] update [ptt-alertor](https://github.com/Ptt-Alertor/ptt-alertor) task definition
* [x] deactivate former account
