# Ptt Alertor AWS Cloudformation

## [Command](http://docs.aws.amazon.com/cli/latest/reference/cloudformation/index.html#cli-aws-cloudformation)

* Validate Stack

```bash
aws cloudformation validate-template --template-body file://./s3/s3.json
```

* Create Stack

```bash
aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name Production-S3 --template-body file://./s3/s3.json
```

* Update Stack

```bash
aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name Production-S3 --template-body file://./s3/s3.json
```

## Checklist

* [x] Create Stack in order
  * [x] vpc
  * [x] ecr
  * [x] ecs-hosts
  * [x] ecs-cluster
  * [x] redis
  * [x] s3
    * [x] new s3 bucket name
    * [x] migrate s3 folders and files
  * [x] service-ptt-alertor
  * [x] sns
  * [x] cloudwatch
    * [x] copy dashboard source from console to `dashboard.yml`
  * [x] elasticsearch
  * [x] acm
* [x] migrate redis db
* [x] DNS change
* [x] migrate elasticsearch and kibana setting
* [x] setting travis ci
  * [x] aws key
  * [x] s3 bucket name