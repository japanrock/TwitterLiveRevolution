#!/usr/bin/env ruby
# coding: utf-8

require 'rubygems'
require 'oauth'
require 'json'
require 'hpricot'
require 'open-uri'
require 'yaml'
require 'parsedate'

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

class Feed
  attr_reader :publisheds
  attr_reader :titles
  attr_reader :links
  
  def initialize
    @all_publisheds = []
    @all_titles     = []
    @all_links      = []
    @publisheds = []
    @titles     = []
    @links      = []
  end

  def filter
    return self if @all_publisheds.empty?

    @all_publisheds.each do|published|
      published = ParseDate::parsedate(published.inner_html)[0..-3].join(',').split(/,/)

      if Time.now < Time.local(published[0].to_i, published[1].to_i, published[2].to_i, published[3].to_i, published[4].to_i, published[5].to_i) + interval
        @publisheds << published.join(',')
      end
    end

    @publisheds
  end

  private
  def open_feed(feed_name)
    Hpricot(open(base_url + feed_name))
  end

  def make_elems(feed)
    if feed.class == Hpricot::Doc
      (feed/'published').each do |published|
        @all_publisheds << published
      end

      (feed/'title').each do |title|
        @all_titles << title
      end
    
      (feed/'link').each do |link|
        @all_links << link
      end   
    end

    self
  end

  def interval
    60 * 60 * 24
  end
end

class LiveRevolution < Feed
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

class PresidentBlog < Feed
  def base_url
    "http://www.president-blog.com/"
  end

  def feed
    make_elems(pen_feed("?mode=atom"))
  end
end

twitter_base    = TwitterBase.new
live_revolution = LiveRevolution.new
president_blog  = PresidentBlog.new

lr_news_feed = live_revolution.news_feed
lr_news_feed.filter
