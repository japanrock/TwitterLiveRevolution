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
require File.dirname(__FILE__) + '/twitter_oauth'

# Usage:
#  1. このファイルと同じディレクトリに以下３つのファイルを設置します。
#   * twitter_oauth.rb
#   * http://github.com/japanrock/TwitterTools/blob/master/twitter_oauth.rb
#   * sercret_key.yml
#   * http://github.com/japanrock/TwitterTools/blob/master/secret_keys.yml.example
#  2. このファイルを実行します。
#   ruby lr_twitter_bot.rb

# フィードを扱う基本クラス
class Feed
  attr_reader :publisheds
  attr_reader :titles
  attr_reader :links
  
  def initialize
    @all_publisheds = []
    @all_titles     = []
    @all_links      = []
    @all_descriptions = []
    @publisheds = []
    @titles     = []
    @links      = []
    @descriptions = []
  end

  # フィード全体から「実行時間からintervalの間のフィード」を抽出します。
  # @titles, @links, @publisheds にフィルターから抽出されたデータをセットします。
  def filter
    return self if @all_publisheds.empty?

    @all_publisheds.each_with_index do|published, index|
      published = ParseDate::parsedate(published)[0..-3].join(',').split(/,/)

      if Time.now < Time.local(published[0].to_i, published[1].to_i, published[2].to_i, published[3].to_i, published[4].to_i, published[5].to_i) + gmt_mode_japan + interval
        @publisheds << published.join(',')
        @titles << Kconv.toutf8(@all_titles[index])
        @links << @all_links[index]
        @descriptions << @all_descriptions[index]
      end
    end
  end

  def header
    ''
  end

  private
  # GMTののフィード時間を日本と合わせるために利用します
  def gmt_mode_japan
    60 * 60 * 9
  end

  # フィードをHpricotのオブジェクトにします。
  def open_feed(feed_name = '')
    Hpricot(open(base_url + feed_name))
  end

  def make_elems(feed)
   self
  end

  # 実行からどのくらい前までのフィードを取得するか
  def interval
    60 * 60 * 24
  end
end

# コーポレートサイトのフィードを扱うクラス
class LiveRevolution < Feed
  def base_url
    "http://www.live-revolution.co.jp/"
  end

  def news_feed
    make_elems(open_feed("atom_0093news.xml")).filter
  end

  def adc_news_feed
    make_elems(open_feed("atom_0060adc_news.xml")).filter
  end
  
  def adc_maintenance_news_feed
    make_elems(open_feed("adc_news_maintenance.xml")).filter
  end

  # Hpricotのオブジェクトから各インスタンス変数に配列としてセットします。
  # @all_publishdesには時間
  # @all_titlesにはタイトル
  # @all_linksにはリンクURL
  def make_elems(feed)
    if feed.class == Hpricot::Doc
      (feed/'entry'/'published').each do |published|
        @all_publisheds << published.inner_html
      end

      (feed/'entry'/'title').each do |title|
        @all_titles << title.inner_html
      end
    
      (feed/'entry'/'link').each do |link|
        @all_links << link.attributes['href']
      end   
    end

    self
  end
end

# プレジデントブログのフィードを扱うクラス
class PresidentBlog < Feed
  def base_url
    "http://www.president-blog.com/"
  end

  def feed
    make_elems(open_feed("?mode=atom")).filter
  end

  # Hpricotのオブジェクトから各インスタンス変数に配列としてセットします。
  # @all_publishdesには時間
  # @all_titlesにはタイトル
  # @all_linksにはリンクURL
  def make_elems(feed)
    if feed.class == Hpricot::Doc
      (feed/'issued').each do |issued|
        @all_publisheds << issued.inner_html
      end

      (feed/'title').each do |title|
        @all_titles << title.inner_html
      end
    
      (feed/'link').each do |link|
        @all_links << link.attributes['href']
      end   
    end

    # headがentryと並列にいるのでheadを削除
    @all_titles.delete_at(0)
    @all_links.delete_at(0)

    self
  end

  def header
    '[pb]'
  end

  private
  def gmt_mode_japan
    0 
  end
end

# プレジデントビジョンのフィードを扱うクラス
class PresidentVision < Feed
  attr_reader :descriptions

  def base_url
    "http://feeds.feedburner.com/president-vision/BJYz"
  end

  def feed
    make_elems(open_feed).filter
  end

  # Hpricotのオブジェクトから各インスタンス変数に配列としてセットします。
  # @all_publishdesには時間
  # @all_titlesにはタイトル
  # @all_linksにはリンクURL
  def make_elems(feed)
    if feed.class == Hpricot::Doc
      (feed/'channel'/'item'/'pubdate').each do |pubdate|
        @all_publisheds << pubdate.inner_html
      end

      (feed/'channel'/'item'/'title').each do |title|
        @all_titles << title.inner_html
      end
    
      (feed/'channel'/'item'/'guid').each do |link|
        @all_links << link.inner_html
      end   

      (feed/'channel'/'item'/'description').each do |description|
        @all_descriptions << description.inner_html
      end
    end

    self
  end

  def header
    '[pv]'
  end

  private
  def gmt_mode_japan
    0 
  end
end


twitter_oauth = TwitterOauth.new

# Live Revolution ADC++ Maintenance News Feed Post
live_revolution  = LiveRevolution.new
live_revolution.adc_maintenance_news_feed
live_revolution.titles.each_with_index do |title, index|
  twitter_oauth.post(title + " - " + live_revolution.links[index])
end

# Live Revolution ADC++ News Feed Post
live_revolution  = LiveRevolution.new
live_revolution.adc_news_feed
live_revolution.titles.each_with_index do |title, index|
  twitter_oauth.post(title + " - " + live_revolution.links[index])
end

# Live Revolution News Feed Post
live_revolution  = LiveRevolution.new
live_revolution.news_feed
live_revolution.titles.each_with_index do |title, index|
  twitter_oauth.post(title + " - " + live_revolution.links[index])
end

# President Vision Feed Post
president_vision = PresidentVision.new
president_vision.feed
president_vision.titles.each_with_index do |title, index|
  twitter_oauth.post(president_vision.header + president_vision.descriptions[index] + " - " + president_vision.links[index])
end

# President Blog Feed Post
president_blog   = PresidentBlog.new
president_blog.feed
president_blog.titles.each_with_index do |title, index|
  twitter_oauth.post(president_blog.header + title + " - " + president_blog.links[index])
end
