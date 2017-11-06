require 'securerandom'
require_relative 'secrets_backend'
require_relative '../helper/misc'

class Secrets
  attr_reader :environment, :app_home
  def initialize(environment,backend_credentials,region,app_home_relative)
    @environment = environment
    @app_home = absolute_path(app_home_relative)
    @variables = JSON.load(File.read("#{app_home}/variables.json"))
    @backend = SecretsBackend.new(backend_credentials,region)
  end

  def get(db=false)
    s3_secrets = @backend.read(s3_bucket,s3_object_path)
    if s3_secrets.nil?
      if db == 'rds'
        Log.warn("No credentials found for RDS at S3://#{s3_bucket}/#{s3_object_path}!!")
        Log.warn("Generating credentials.....")
        s3_secrets = get_db_credentials(@variables['app'].upcase)
        put s3_secrets
      elsif db == 'ec2'
        Log.warn("No credentials found for EC2 DB at S3://#{s3_bucket}/#{s3_object_path}!!")
        Log.warn("Generating credentials.....")
        s3_secrets = get_db_credentials(@variables['appuser'].upcase)
        put s3_secrets
      else
        Log.error("S3 object not found at PATH: S3://#{s3_bucket}/#{s3_object_path}!!")
      end
    end
    secrets = (JSON.parse s3_secrets).merge!(get_dependent_secrets)
    File.write("#{app_home}/#{@variables['appFullName']}.json",secrets.to_json)
    return secrets
  end

  def put body
    @backend.write(s3_bucket,s3_object_path,body)
  end

  def download(s3_path,target_path)
    Log.info("Downloading File from: S3://#{s3_bucket}/#{s3_object_path}")
    @backend.get_file(s3_bucket,s3_path,target_path)
  end

  private
  def get_db_credentials(appuser)
    db_creds
    data = {}
    data["#{appuser}_DB_ADMIN_USER"] = "#{appuser.downcase}admin"
    data["#{appuser}_DB_ADMIN_PASSWORD"] = db_creds[0].to_s
    data["#{appuser}_DB_APPLICATION_PASSWORD"] = db_creds[1].to_s
    data["#{appuser}_DB_PORT"] = 5432
    data["#{appuser}_DB_HOST"] = ""
    return JSON.pretty_generate(data)
  end

  def s3_bucket
    return @variables[@environment]['SecretsBucket']
  end
  def s3_object_path
    return "environment_variables/#{@variables['appFullName']}/#{@environment}/#{@variables['appFullName']}.json"
  end

  def db_creds
    db_passwd = SecureRandom.base64(32)
    app_passwd = SecureRandom.base64(32)
    allowed_char = [ ['"', ''], ['/', ''], ['@', ''], ['=', ''] ]
    allowed_char.each {|replace| db_passwd.gsub!(replace[0], replace[1])}
    allowed_char.each {|replace| app_passwd.gsub!(replace[0], replace[1])}
    return db_passwd,app_passwd
  end

  def get_dependent_secrets
    dependent_secrets = {}
    if @variables[@environment]['dependentEnvVars']
      @variables[@environment]['dependentEnvVars'].each { |var_file| dependent_secrets.merge!(JSON.parse(@backend.read(s3_bucket,var_file))) }
    end
    return dependent_secrets
  end
end
