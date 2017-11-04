# Deploy EC2 Host for ECS-cluster

## Great features

- Runs docker with ECS agent
- Authenticate ECS agent to private docker registry
- Report metrics to Newrelic
- Split docker logs into containers/<service name>.log (according to the tag given to syslog)
- Rotate logs using Logrotate to avoid disk filling
- Forward logs to the log-server (address in variables.json)

## Requirements

- rsyslog v8.x rpm should be available on custom yum repo (repo.tabdigital.com.au)
- monit v5.x rpm should be available on custom yum repo (repo.tabdigital.com.au)
- Configuration files should be present on S3:
  * Newrelic config/ license - `s3://<environment_config_bucket>/ecs_hosts/%{environment}/nrsysmond.cfg`
  * ECS.config file with authentication token - `s3://<environment_config_bucket>/ecs_hosts/%{environment}/ecs.config`
  * Docker config.json with authentication token - `s3://<environment_config_bucket>/docker_hosts/config.json`
  * Application keys (e.g. token_encryption.key & user_checksum.salt) - `s3://<environment_config_bucket>/environment_variables/authentication-keys/%{environment}/keys/`
- Use latest ECS optimized AMI from: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html

## Deployment

From deployment (current) repo, browse path `cloudformation/`
```
$ bundle install
$ bundle exec rake cf:template_json[UAT,src/platform/redbook/ecs-hosts]     # generate cloudformation template
```

To deploy cloudformation:
```
$ bundle exec rake cf:ec2_hosts[<environment>,<aws_profile>,<region>,<cloudformation_template_path>,<ami_id>]     # generate cloudformation template
```
Example:
```
$ bundle exec rake cf:ec2_hosts[UAT,sunbets-digital-development,ap-southeast-2,src/platform/redbook/ecs-hosts,ami-fbe9eb98]     # deploy cloudformation stack
```
