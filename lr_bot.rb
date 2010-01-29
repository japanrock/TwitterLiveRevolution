#!/usr/bin/env ruby
# coding: utf-8

require 'rubygems'
require 'oauth'
require 'json'
require 'hpricot'
require 'open-uri'
require 'yaml'

class LiveRevolution
  def initialize
    @secret_keys = YAML.load_file("secret_keys.yml.example")
  end
  
  def consumer_key
    @secret_keys["ConsumerKey"]
  end

  def consumer_secret
    @secret_keys["ConsumerSecret"]
  end

  def access_token
    @secret_keys["AccessToken"]
  end

  def access_token_secret
    @secret_keys["AccessTokenSecret"]
  end

  def consumer
    consumer = OAuth::Consumer.new(
      CONSUMER_KEY,
      CONSUMER_SECRET,
      :site => 'http://twitter.com'
    )
  end

  def access_token
    access_token = OAuth::AccessToken.new(
      consumer,
      ACCESS_TOKEN,
      ACCESS_TOKEN_SECRET
    )
  end

  def base_url
    "http://www.live-revolution.co.jp"
  end

  def news_feed
    Hpricot(open("#{base_url}/atom_0093news.xml"))
  end

  def adc_news_feed
    Hpricot(open("#{base_url}/atom_0060adc_news.xml"))
  end
end

live_revolution = LiveRevolution.new
