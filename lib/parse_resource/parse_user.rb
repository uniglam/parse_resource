require 'parse_resource/parse_user_validator'
require "uri"

class ParseUser < ParseResource::Base
  fields :username, :password

  def self.authenticate(username, password)
    base_uri   = "#{Rails.application.secrets.parse_url}login"
    begin
      resp = self.resource.get(:params => {:username => URI::encode(username), :password => URI::encode(password)})
      user = model_name.to_s.constantize.new(JSON.parse(resp), false)
      user
    rescue Exception => e
      false
    end

  end

  def self.authenticate_with_facebook(user_id, access_token, expires)
    base_uri   = "#{Rails.application.secrets.parse_url}users"
    app_id     = settings['app_id']
    master_key = settings['master_key']
    resource = RestClient::Resource.new(base_uri, app_id, master_key)

    begin
      resp = resource.post(
          { "authData" =>
                            { "facebook" =>
                                  {
                                      "id" => user_id,
                                      "access_token" => access_token,
                                      "expiration_date" => Time.now + expires.to_i
                                  }
                            }
                      }.to_json,
                     :content_type => 'application/json', :accept => :json)
      user = model_name.to_s.constantize.new(JSON.parse(resp), false)
      user
    rescue
      false
    end
  end

  def self.reset_password(email)
      base_uri   = "#{Rails.application.secrets.parse_url}requestPasswordReset"
      app_id     = settings['app_id']
      master_key = settings['master_key']
      resource = RestClient::Resource.new(base_uri, app_id, master_key)

      begin
        resp = resource.post({:email => email}.to_json, :content_type => 'application/json')
        true
      rescue
        false
      end
  end
end
