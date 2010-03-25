#!/usr/bin/env ruby
# coding: utf-8

require 'rubygems'
require 'oauth'
require 'json'
require 'hpricot'
require 'open-uri'
require 'yaml'
require 'parsedate'
require "kconv"

###
### TwitterBaseクラスはあとで外に出す
###

# config.ymlについて
#   config.ymlには sercret_keys.yml への絶対パスを１行で書いてください。
#
# live-revolution_twitter.rbの使い方について
#   config.ymlをセットして実行します。
#     Usage:
#       ruby live-revolution_twitter.rb /path/to/config.yml

# TwitterのAPIとのやりとりを行うクラス
class TwitterBase
  def initialize
    # gets.chompはconfig.ymlに書かれたsercret_keys.ymlを取得します。
    # config.yml内のsercret_keys.ymlをloadします。
    @secret_keys = YAML.load_file(gets.chomp)
  end
  
  def consumer_key
    @secret_keys["ConsumerKey"]
  end

  def consumer_secret
    @secret_keys["ConsumerSecret"]
  end

  def access_token_key
    @secret_keys["AccessToken"]
  end

  def access_token_secret
    @secret_keys["AccessTokenSecret"]
  end

  def consumer
    @consumer = OAuth::Consumer.new(
      consumer_key,
      consumer_secret,
      :site => 'http://twitter.com'
    )
  end

  def access_token
    consumer
    access_token = OAuth::AccessToken.new(
      @consumer,
      access_token_key,
      access_token_secret
    )
  end

  def post(tweet=nil)
    response = access_token.post(
      'http://twitter.com/statuses/update.json',
      'status'=> tweet
    )
  end
end

class LiveRevolutionCulture
  attr_reader :selected_culture
  attr_reader :select

  def initialize
    @culture = YAML.load_file('culture.yml')
  end

  # ここはあとでリファクタリング・・・微妙なので・・・
  def head
    if @select < 47
      "[culture]"
    else
      "[lrheart]"
    end
  end

  def random_select
    @selected_culture = @culture[select]
  end

  # ポストする範囲を指定する
  def select
    @select = rand(106)
  end
end

# twitter_base     = TwitterBase.new

live_revolution_culture  = LiveRevolutionCulture.new
content  = live_revolution_culture.random_select
head     = live_revolution_culture.head
url      = live_revolution_culture.selected_culture["url"]
contents = live_revolution_culture.selected_culture["contents"]

#twitter_base.post(head + contents + " - " + url)
puts head + contents + " - " + url
