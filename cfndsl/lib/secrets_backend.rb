require 'aws-sdk'
require_relative 'credentials'

class SecretsBackend
  def initialize(credentials,region)
    @s3_client = Aws::S3::Client.new(credentials: Credentials.get(credentials,region), region: region)
  end

  def read bucket_name,path
    Log.info "Reading environment variables from:- \"S3://#{bucket_name}/#{path}\""
    response = nil
    begin
      response = @s3_client.get_object(bucket: bucket_name, key: path)
    rescue Aws::S3::Errors::NoSuchKey => e
      Log.error_and_continue "PATH:- \"S3://#{bucket_name}/#{path}\" does not exist."
      return nil
    end
    response.body.read.strip()          # returns response in JSON format
  end

  def write bucket_name,path,body
    Log.info "Adding DB-Environment variables to:- \"S3://#{bucket_name}/#{path}\""
    response = nil
    begin
      response = @s3_client.put_object(bucket: bucket_name, key: path, body: body)
    rescue Aws::S3::Errors::NoSuchKey => e
      Log.error_and_continue "Not able to write PATH:- \"S3://#{bucket_name}/#{path}\"."
      return nil
    end
  end

  def get_file bucket_name,path,target
    Log.info "Checkign file from path:- \"S3://#{bucket_name}/#{path}\""
    response = nil
    begin
      response = @s3_client.get_object({bucket: bucket_name, key: path}, response_target: target)
    rescue Aws::S3::Errors::NoSuchKey => e
      Log.error_and_continue "FILE:- \"S3://#{bucket_name}/#{path}\" does not exist."
      return nil
    end
  end

end
