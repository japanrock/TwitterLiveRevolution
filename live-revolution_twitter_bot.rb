#!/usr/bin/env ruby
# coding: utf-8

require 'rubygems'
require 'oauth'
require 'json'
require 'hpricot'
require 'open-uri'
require 'yaml'

class TwitterBase
  def initialize
    @secret_keys = YAML.load_file("secret_keys.yml")
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
end

class Site
  private
  def open_feed(feed_name)
    Hpricot(open(base_url + feed_name))
  end

  def make_elems(feed)
    if feed.class == Hpricot::Doc
      elems = []
      (feed/'entry').each do |elem|
        elems << elem
      end
    end

    elems
  end
end

class LiveRevolution < Site
  def base_url
    "http://www.live-revolution.co.jp/"
  end

  def news_feed
    make_elems(open_feed("atom_0093news.xml"))
 end

  def adc_news_feed
    make_elems(open_feed("atom_0060adc_news.xml"))
  end
  
  def adc_maintenance_news_feed
    make_elems(open_feed("adc_news_maintenance.xml"))
  end
end

class PresidentBlog < Site
  def base_url
    "http://www.president-blog.com/"
  end

  def feed
    omake_elems(pen_feed("?mode=atom"))
  end
end

twitter_base    = TwitterBase.new
live_revolution = LiveRevolution.new
president_blog  = PresidentBlog.new

lr_news_elems = live_revolution.news_feed
