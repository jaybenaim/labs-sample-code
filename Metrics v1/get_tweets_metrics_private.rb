require 'oauth'
require 'yaml'
require 'json'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'

# Authentication

# Add your API key here
@consumer_key = ''

# Add your API secret key here 
@consumer_secret = '' 

@consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret,
                                :site => 'https://api.twitter.com',
                                :authorize_path => '/oauth/authenticate',
                                :debug_output => false)

@request_token = @consumer.get_request_token()

@token = @request_token.token
@token_secret = @request_token.secret
puts "Authorize via this URL: #{@request_token.authorize_url()}"
puts "Enter PIN: "
@pin = gets.strip

@hash = { :oauth_token => @token, :oauth_token_secret => @token_secret}
@request_token  = OAuth::RequestToken.from_hash(@consumer, @hash)
@access_token = @request_token.get_access_token({:oauth_verifier => @pin})

puts "Looking up Tweet metrics with new access token"

# Parameters: Add up to 50 comma-separated Tweet ID(s) you wish to query here
@TweetIDs = ''

@uri = "https://api.twitter.com/labs/1/tweets/metrics/private?ids=%s" % [@TweetIDs]  
@options = {
    :method => :get
}
@oauth_params = {
    :consumer => @consumer,
    :token => @access_token
}
@hydra = Typhoeus::Hydra.new
@req = Typhoeus::Request.new(@uri, @options)
@oauth_helper = OAuth::Client::Helper.new(@req, @oauth_params.merge(:request_uri => @uri))
@req.options[:headers].merge!({"Authorization" => @oauth_helper.header}) # Signs the request
@hydra.queue(@req)
@hydra.run
@response = @req.response

puts @response.body
