require 'rubygems'
require 'oauth'
require 'twitter'

#puts "opning #{request_token.authorize_url}"
#%x{open #{request_token.authorize_url}}

#puts "input verifier"
#verifier = gets.chop


#p access_token.token
#p access_token.secret

class TweetOnlyClient
  SITE = 'http://twitter.com/'
  ACCESS_TOKEN_URL = 'http://twitter.com/oauth/access_token'
  REQUEST_TOKEN_URL = 'http://twitter.com/oauth/request_token'
  CONSUMER_KEY = 'DxqbdCqZkI1WgKOEg1klsQ'
  CONSUMER_SECRET = 'fQj9GqVZrQS6IcqZRkXKrCOMqSodYA5BxPURUco'
  RC_FILE = '~/.tweetonlyrc'

  def initialize
    begin
      File.open(File.expand_path(RC_FILE), 'r') {|f|
        f.readlines.each {|l|
          la = l.split(' ')
          case la[0]
          when 'ACCESS_TOKEN'
            @access_token_token = la[1]
          when 'ACCESS_SECRET'
            @access_token_secret = la[1]
          else
            # nop
          end
        }
      }
    rescue
      # nop
    end

    if @access_token_token and @access_token_secret
      @authorized = true
    else
      @authorized = false
    end
  end
  attr_reader :authorized

  def twitter_oauth
    oauth = Twitter::OAuth.new(CONSUMER_KEY, CONSUMER_SECRET)
    oauth.authorize_from_access(@access_token_token, @access_token_secret)
    @client = Twitter::Base.new(oauth)
  end

  def authorize
     consumer = OAuth::Consumer.new(
      CONSUMER_KEY,
      CONSUMER_SECRET,
      {:site => SITE}
    )
    @request_token = consumer.get_request_token
    return @request_token.authorize_url
  end

  def verifier(v)
    access_token = @request_token.get_access_token(
      :oauth_token => @request_token.token,
      :oauth_verifier => v
    )
    @access_token_token = access_token.token
    @access_token_secret = access_token.secret
    save_access_token

    @authorized = true

    return true
  end

  def save_access_token
      File.open(File.expand_path(RC_FILE), 'w') {|f|
        f.puts "ACCESS_TOKEN #{@access_token_token}"
        f.puts "ACCESS_SECRET #{@access_token_secret}"
      }
    return true
  end

  def tweet(text)
    if @authorized
      @client.update(text)
      return true
    else
      return false
    end
  end
end

#client = TweetOnlyClient.new(CONSUMER_KEY, CONSUMER_SECRET)
#unless client.authorized?
#  authorize_url = client.authorize
#  %x{open #{authorize_url}}
#  print "input verifier: "
#  v = gets.chop
#  unless client.verifier(v)
#    puts "Authorize failed"
#    exit(1)
#  end
#  puts "Authorize succeeded"
#end

