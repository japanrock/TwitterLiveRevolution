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
### TwitterBase���饹�Ϥ��Ȥǳ��˽Ф�
###

# config.yml�ˤĤ���
#   config.yml�ˤ� sercret_keys.yml �ؤ����Хѥ��򣱹Ԥǽ񤤤Ƥ���������
#
# live-revolution_twitter.rb�λȤ����ˤĤ���
#   config.yml�򥻥åȤ��Ƽ¹Ԥ��ޤ���
#     Usage:
#       ruby live-revolution_twitter.rb /path/to/config.yml

# Twitter��API�ȤΤ��Ȥ��Ԥ����饹
class TwitterBase
  def initialize
    # gets.chomp��config.yml�˽񤫤줿sercret_keys.yml��������ޤ���
    # config.yml���sercret_keys.yml��load���ޤ���
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

  # �����Ϥ��Ȥǥ�ե�������󥰡�������̯�ʤΤǡ�����
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

  # �ݥ��Ȥ����ϰϤ���ꤹ��
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
