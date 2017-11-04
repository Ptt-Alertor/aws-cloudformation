absolute_path = File.dirname(__FILE__)
variables = JSON.load(File.read("#{absolute_path}/variables.json"))
environment = extras[:environment]
mappings = variables['mappings'][environment]

CloudFormation {
  Description "#{environment} VPC"

  Resource('VPC') {
    Type "AWS::EC2::VPC"
    Property "CidrBlock", mappings["VpcCIDR"]
    Property "EnableDnsHostnames", true
    Property "InstanceTenancy", "default"
    Property "Tags", [{
      Key: "Name",
      Value: "#{environment}-VPC",
    }]
  }

  Resource('InternetGateway') {
    Type "AWS::EC2::InternetGateway"
    Property "Tags", [{
      Key: "Name",
      Value: "#{environment} Internet Gateway",
    }]
  }

  Resource('VPCGatewayAttachment') {
    Type "AWS::EC2::VPCGatewayAttachment"
    Property "VpcId", Ref("VPC")
    Property "InternetGatewayId", Ref("InternetGateway")
  }

  Resource("PublicSubnet") {
    Type "AWS::EC2::Subnet"
    Property "AvailabilityZone", mappings["AvailabilityZone"]
    Property "CidrBlock", mappings["PublicCIDR"]
    Property "VpcId", Ref("VPC")
    Property "Tags", [{
      Key: "Name",
      Value: "#{environment}-PublicSubnet",
    }]
  }
  Resource("PublicSubnetRT") {
    Type "AWS::EC2::RouteTable"
    Property "VpcId", Ref("VPC")
    Property "Tags", [{
      Key: "Name",
      Value: "#{environment}-PublicSubnet-RouteTable",
    }]
  }

  Resource("PublicSubnetRouteAssociation") {
    Type "AWS::EC2::SubnetRouteTableAssociation"
    Property "RouteTableId", Ref("PublicSubnetRT")
    Property "SubnetId", Ref("PublicSubnet")
  }

  Resource("PublicSubnetRoute") {
    Type "AWS::EC2::Route"
    DependsOn "VPCGatewayAttachment"
    Property "DestinationCidrBlock", "0.0.0.0/0"
    Property "GatewayId", Ref("InternetGateway")
    Property "RouteTableId", Ref("PublicSubnetRT")
  }

  Output("PublicSubnet") {
    Description "PublicSubnet"
    Value Ref("PublicSubnet")
    Export FnJoin("", [Ref("AWS::StackName"), "-PublicSubnet"])
  }

  Output("AvailabilityZone") {
    Description "AvailabilityZone"
    Value mappings['AvailabilityZone']
    Export FnJoin("", [Ref("AWS::StackName"), "-AvailabilityZone"])
  }

  Output('Region') {
    Description "Region"
    Value mappings['Region']
    Export FnJoin("", [Ref("AWS::StackName"), "-Region"])
  }
  Output('VpcCIDR') {
    Description "VpcSubnet"
    Value mappings['VpcCIDR']
    Export FnJoin("", [Ref("AWS::StackName"), "-VpcCIDR"])
  }
  Output('VpcId') {
    Value Ref("VPC")
    Description "VPC ID"
    Export FnJoin("", [Ref("AWS::StackName"), "-VpcId"])
  }
}