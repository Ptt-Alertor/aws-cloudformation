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