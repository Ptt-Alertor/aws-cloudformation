### Usage and Script
Convert Ruby code into Json
Ref: https://github.com/cfndsl/cfndsl

# Install Library
```
bundle install --path .bundle
```

# Environment Variable 
```
Profile="Production"
Environment="Production"
Region='us-west-2'
```

# VPC 
```
APP='VPC'
bundle exec rake cf:template_json[$Environment,$APP]
bundle exec rake cf:deploy_default[$Profile,$Environment,$Region,$APP]
```

# ECS Cluster
```
APP='ecs-cluster'
bundle exec rake cf:template_json[$Environment,$APP]
bundle exec rake cf:deploy_default[$Profile,$Environment,$Region,$APP]
```
# ECS Host
```
APP='ecs-hosts'
bundle exec rake cf:template_json[$Environment,$APP]
bundle exec rake cf:deploy_default[$Profile,$Environment,$Region,$APP]
```

# Redis 
```
APP='redis'
bundle exec rake cf:template_json[$Environment,$APP]
bundle exec rake cf:deploy_default[$Profile,$Environment,$Region,$APP]
```

# ECS Service
```
APP='service-ptt-alertor'
bundle exec rake cf:template_json[$Environment,$APP]
bundle exec rake cf:deploy_default[$Profile,$Environment,$Region,$APP]
```

