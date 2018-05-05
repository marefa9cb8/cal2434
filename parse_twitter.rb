require "twitter"
require 'yaml'
require 'time'

class TwitterClient
  attr_reader :client

  def initialize()
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  # @nijisanji_app
  def get_user_timeline
    return @client.user_timeline("nijisanji_app", tweet_mode: "extended", count: 200)
  end

  def get_schedule
    schedules = []
    puts get_user_timeline.length
    get_user_timeline.each do |tweet|
      text = tweet.attrs[:full_text]
      # 1day only (+1h)
      next if Time.now - tweet.created_at > 86400 + 3600
      if text.include?("☆Liveスケジュール☆") then
        day = nil
        uri = tweet.uri.to_s
        text.each_line {|line|
          start_time = nil
          end_time = nil
          title = nil
          if date = line.match(/([0-9]+)\/([0-9]+).*/) then
            # puts date[0]
            day = Date.strptime(Time.now.year.to_s + "-" + date[1] + "-" + date[2], '%Y-%m-%d')
            next
          elsif time = line.match(/([0-9]{,2}):([0-9]{2})~([0-9]{,2}):([0-9]{2}) (.*)/) then
            # puts time[0]
            start_time = {'hour' => time[1], 'min' => time[2]}
            end_time = {'hour' => time[3], 'min' => time[4]}
            title = time[5]
          end
        data = {'date' => day, 'time' => start_time, 'end_time' => end_time, 'title' => title, 'uri' => uri} unless title.nil?
        schedules.push(data) unless data.nil?
        data = nil
        }
      end
    end
    return schedules
  end
end

tw = TwitterClient.new
schedule = tw.get_schedule
YAML.dump(schedule, File.open('twitter+.yaml', 'a+'))
