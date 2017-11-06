require_relative "../lib/secrets"

namespace :get_secret do

  desc 'Read app environment variables from S3. Usage:- bundle exec rake get_secret:app[UAT,sunbets-digital-development,ap-southeast-2,src/apps/www-casino]'
  task :app, [:environment, :aws_profile, :region, :app_home] do |t, args|
    exit_on_mandatory_rake_arguments args, :environment, :aws_profile, :region, :app_home
    creds_params = {
      mode: 'aws_profile',
      profile_name: args[:aws_profile]
    }
    secrets = Secrets.new(args[:environment],creds_params,args[:region],args[:app_home])
    secrets.get()
  end

  desc 'Read Postgres-DB credentials from S3. Usage:- bundle exec rake get_secret:ec2db[UAT,sunbets-digital-development,ap-southeast-2,src/apps/www-casino]'
  task :ec2db, [:environment, :aws_profile, :region, :app_home] do |t, args|
    exit_on_mandatory_rake_arguments args, :environment, :aws_profile, :region, :app_home
    creds_params = {
      mode: 'aws_profile',
      profile_name: args[:aws_profile]
    }
    secrets = Secrets.new(args[:environment],creds_params,args[:region],args[:app_home])
    secrets.get(db='ec2')
  end

  desc "Read RDS-DB credentials from S3. Usage:- bundle exec rake get_secret:rds[UAT,sunbets-digital-development,ap-southeast-2,src/apps/api-service-announcement]"
  task :rds, [:environment, :aws_profile, :region, :app_home] do |t, args|
    exit_on_mandatory_rake_arguments args, :environment, :aws_profile, :region, :app_home
    creds_params = {
      mode: 'aws_profile',
      profile_name: args[:aws_profile]
    }
    secrets = Secrets.new(args[:environment],creds_params,args[:region],args[:app_home])
    secrets.get(db='rds')
  end

end
