=begin
creds_params = {
  mode: 'aws_profile | iam_role_arn | aws_access_key',
  profile_name: 'profile name',
  iam_role_arn: 'iam_role_arn',
  access_key_id: 'access_key_id | ENV['AWS_ACCESS_KEY_ID']',
  secret_access_key: 'secret_access_key | ENV['AWS_SECRET_ACCESS_KEY']',
  session_token: 'session_token | ENV['AWS_SESSION_TOKEN'] (optional. Needed if profile is federated access)'
}
=end
require_relative '../helper/log'
require 'securerandom'
require 'pp'

class Credentials
  class << self
    def get(params,region)
      if valid_params?(params)
        case params[:mode]
        when 'aws_profile'
          Aws::SharedCredentials.new(profile_name: params[:profile_name]).credentials
        when 'iam_role_arn'
          Aws::AssumeRoleCredentials.new(
            role_arn: params[:iam_role_arn],
            role_session_name: SecureRandom.hex(4),
            region: region
          ).credentials
        when 'aws_access_key'
          Aws::Credentials.new(
            params[:access_key_id] || ENV['AWS_ACCESS_KEY_ID'],
            params[:secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY'],
            params[:session_token] || ENV['AWS_SESSION_TOKEN']
          )
        end
      else
        Log.error_and_continue "Invalid credentials params"
        Log.error_and_continue "Expected value in format given below"
        usage
      end
    end

    private
    def usage
      creds_params = {
        mode: 'aws_profile | iam_role_arn | aws_access_key',
        profile_name: 'profile name',
        iam_role_arn: 'iam_role_arn',
        access_key_id: 'access_key_id | ENV[\'AWS_ACCESS_KEY_ID\']',
        secret_access_key: 'secret_access_key | ENV[\'AWS_SECRET_ACCESS_KEY\']',
        session_token: 'session_token | ENV[\'AWS_SESSION_TOKEN\'] (optional. Needed if profile is federated access)'
      }
      pp creds_params
      exit 1
    end
    def valid_params?(params)
      case params[:mode]
      when 'aws_profile'
        return false if params[:profile_name].nil?
      when 'iam_role_arn'
        return false if params[:iam_role_arn].nil?
      when 'aws_access_key'
        return false if params[:access_key_id].nil? && ENV['AWS_ACCESS_KEY_ID'].nil?
        return false if params[:secret_access_key].nil? && ENV['AWS_SECRET_ACCESS_KEY'].nil?
      else
        return false
      end
      return true
    end
  end
end
