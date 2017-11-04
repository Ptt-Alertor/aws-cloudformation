# Uses https://github.com/stevenjack/cfndsl
absolute_path = File.dirname(__FILE__)
variables = JSON.load(File.read("#{absolute_path}/variables.json"))
environment=extras[:environment]
# get mappings from variables.json
mapping = variables[environment]
stack = mapping['Stack']

CloudFormation {

  Description "#{environment} #{variables['app']}"
  
  Resource('SecurityGroup') {
    Type 'AWS::EC2::SecurityGroup'
    Property 'GroupDescription', 'Allow VPC Access for Redis'
    Property 'VpcId', FnImportValue(FnSub("#{stack['VPC']}-VpcId"))
    Property 'SecurityGroupIngress', [
      {
        IpProtocol: 'tcp',
        FromPort:   variables['RedisPort'],
        ToPort:     variables['RedisPort'],
        CidrIp:     FnImportValue(FnSub("#{stack['VPC']}-VpcCIDR"))
      }
    ]
    Property 'SecurityGroupEgress', [
      {
        IpProtocol: 'tcp',
        FromPort:   variables['RedisPort'],
        ToPort:     variables['RedisPort'],
        CidrIp:     FnImportValue(FnSub("#{stack['VPC']}-VpcCIDR"))
      }
    ]
    Property 'Tags', [
      {
        Key: 'Name',
        Value: FnFormat("#{environment}-#{variables['app']}-sg")
      }
    ]
  }

  Resource('SubnetGroup') {
    Type "AWS::ElastiCache::SubnetGroup"
    Property 'Description', 'Redis SubnetGroup'
    Property 'SubnetIds', [ FnImportValue(FnSub("#{stack['VPC']}-PublicSubnet")) ]
  }

  Resource('Redis') {
    Type 'AWS::ElastiCache::CacheCluster'
    Property 'AutoMinorVersionUpgrade', true
    Property 'AZMode', mapping['AZMode']
    Property 'CacheNodeType', mapping['CacheNodeType']
    Property 'CacheSubnetGroupName', Ref('SubnetGroup')
    Property 'Engine', 'redis'
    Property 'EngineVersion', mapping['EngineVersion']
    Property 'NumCacheNodes', mapping['NumCacheNodes']
    Property 'Port', variables['RedisPort']
    Property 'PreferredMaintenanceWindow', mapping['PreferredMaintenanceWindow']
    Property 'VpcSecurityGroupIds', [ Ref('SecurityGroup') ]
  }

  Output('RedisEndPoint') {
    Value FnGetAtt('Redis', 'RedisEndpoint.Address')
    Description "Redis Endpoint"
    Export FnJoin("", [Ref("AWS::StackName"), "-EndPoint"])
  }
  Output('RedisPort') {
    Value FnGetAtt('Redis', 'RedisEndpoint.Port')
    Description "Redis Port"
    Export FnJoin("", [Ref("AWS::StackName"), "-Port"])
  }
}
