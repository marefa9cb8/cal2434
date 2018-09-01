require 'open-uri'
require 'nokogiri'
require 'yaml'

def read_html(url)
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  return Nokogiri::HTML.parse(html, nil, charset)
end

def parse_day(doc)
  daysets = doc.xpath("//html/body/div/div[4]/table/tr/td/div/table/tr/td[2]/h3")
  dayarray = []
  daysets.each{|dayset|
    text = dayset.text
    if date = text.match(/([0-9]+) ([0-9]+), ([0-9]+)/) then
      dayarray.push(Date.strptime(date[3].to_s + "-" + date[2].to_s + "-" + date[1].to_s, '%Y-%m-%d'))
    end
  }
  return dayarray
end

def parse_title(doc)
  titlesets = doc.xpath("//html/body/div/div[4]/table/tr/td/div/table/tr/td[2]/div")
  titlearray = []
  titlesets.each{|titleset|
    lilist = titleset.xpath("ul/li")
    linearray = []
    lilist.each{|line|
      time = nil
      end_time = nil
      title = nil
      uri = nil
      a_tag = line.at("a")
      unless a_tag.nil? then
        link = a_tag["href"]
        if url = link.match(/http:\/\/re.wikiwiki.jp\/\?(.*)/) then
          uri = url[1]
        end
      end
      if time_title = line.text.match(/([0-9]+)時([0-9]+)分[～~]([0-9]+)時([0-9]+)分[[:blank:]]?+(.*)/) then
        time = {'hour' => time_title[1].to_i, 'min' => time_title[2].to_i}
        end_time = {'hour' => time_title[3].to_i, 'min' => time_title[4].to_i}
        title = time_title[5]
      elsif time_title = line.text.match(/([0-9]+)時([0-9]+)分(以降|頃|ぐらい)?+(～|~)?+[[:blank:]]?+(.*)/) then
        time = {'hour' => time_title[1].to_i, 'min' => time_title[2].to_i}
        title = time_title[5]
      elsif time_title = line.text.match(/未定[[:blank:]](.*)/) then
        title = time_title[1]
      elsif time_title = line.text.match(/(.*)/) then
        title = time_title[1]
      end
      title.gsub!(/■/,'')   if title.include?('■')
      linearray.push({'time' => time, 'end_time' => end_time, 'title' => title, 'uri' => uri}) unless title.nil?
    }
    titlearray.push(linearray)
  }
  return titlearray
end

def make_event(dayarray, titlearray)
  eventarray = []
  dayarray.zip(titlearray){|day,titles|
    titles.each{|title|
      event = {'date' => day, 'time' => title['time'], 'title' => title['title'], 'end_time' => title['end_time'], 'uri' => title['uri']}
      eventarray.push(event)
    }
  }
  return eventarray
end

pages = ['201803', '201804', '201805', '201806', '201807', '201808', '201809', '201810', '201811']
base_url = 'https://wikiwiki.jp/nijisanji/?plugin=minicalendar&file=%E9%85%8D%E4%BF%A1%E4%BA%88%E5%AE%9A&date='
pages.each{|month|
  puts month
  url = base_url + month
  doc = read_html(url)
  day_a = parse_day(doc)
  title_a = parse_title(doc)
  event_a = make_event(day_a, title_a)
  YAML.dump(event_a, File.open('resource/' + month + 'wiki.yaml', 'w'))
}
