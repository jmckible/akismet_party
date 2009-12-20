require 'httparty'

class Akismet
  include HTTParty
  headers 'User-Agent'   =>'akismet_party/0.0.1 | Akismet/1.1', 
          'Content-Type' =>'application/x-www-form-urlencoded'  
  
  class << self
    attr_accessor :key_validated, :key, :blog
    
    def authorize(key, blog, url='rest.akismet.com')
      @@key  = key
      @@blog = blog
      @@url  = url
      default_options[:base_uri] = "http://#{@@url}"
      valid = self.post '/1.1/verify-key', :body=>{:key=>@@key, :blog=>@@blog}
      if valid == 'valid'
        @@key_validated = true
        default_options[:base_uri] = "http://#{@@key}.#{@@url}"
      else
        @@key_validated = false
      end
    end
    
    def is_spam?
      raise 'Invalid API Key' unless @@key_validated == true
      spam = self.post '/1.1/comment-check', :body=>{:comment_author=>'viagra-test-123', :blog=>@@blog, :user_ip=>'127.0.0.1', :user_agent=>'akismet_party/0.0.1 | Akismet/1.1'}
      
      if spam == 'true'
        true
      elsif spam == 'false'
        false
      else
        raise spam # Missing params or somesuch
      end
    end
    
  end
 
end