require 'yaml'
require 'uri'

def formatTime(date, time)
  ret = date.strftime('%Y%m%d')
  ret += 'T' + sprintf('%02d', time['hour']) + sprintf('%02d', time['min']) + '00' unless time.nil?
  ret
end

puts 'BEGIN:VCALENDAR'
puts 'VERSION:2.0'
puts 'PRODID:-//balar//2434 Event Calendar V0.1//JP'

['wiki.yaml'].each do |fn|
  open(fn, 'r') do |f|
    schedule = YAML.load(f)
    schedule.each do |s|
      puts 'BEGIN:VEVENT'
      puts "DTSTART;TZID=Asia/Tokyo:#{formatTime(s['date'], s['time'])}"
      puts "DTEND;TZID=Asia/Tokyo:#{formatTime(s['date'], s['end_time'])}" unless s['end_time'].nil?
      begin
        puts "SUMMARY:#{s['title'].encode("UTF-8", "EUC-JP")}"
      rescue
        puts "SUMMARY:#{s['title']}"
      end
      puts "URL:#{s['uri']}"
      puts "DESCRIPTION:#{s['uri']}"
      puts 'END:VEVENT'
    end
  end
end

puts 'END:VCALENDAR'
