require 'open-uri'
require 'nokogiri'
require 'yaml'

url = 'https://wikiwiki.jp/nijisanji/?plugin=minicalendar_viewer&file=%E9%85%8D%E4%BF%A1%E4%BA%88%E5%AE%9A&mode=future'
#url = 'https://wikiwiki.jp/nijisanji/?plugin=minicalendar_viewer&file=%E9%85%8D%E4%BF%A1%E4%BA%88%E5%AE%9A&mode=pastex'
charset = nil
html = open(url) do |f|
  charset = f.charset
  f.read
end
doc = Nokogiri::HTML.parse(html, nil, charset)

daysets = doc.xpath("//html/body/div/div[4]/table/tr/td[2]/div[1]/h3")
dayarray = []
daysets.each{|dayset|
  text = dayset.text
  if date = text.match(/([0-9]+) ([0-9]+), ([0-9]+)/) then
    dayarray.push(Date.strptime(date[3].to_s + "-" + date[2].to_s + "-" + date[1].to_s, '%Y-%m-%d'))
  end
}

titlesets = doc.xpath("//html/body/div/div[4]/table/tr/td[2]/div[1]/div")
# remove title & footer
titlesets = titlesets[1, titlesets.length-2]
titlearray = []
titlesets.each{|titleset|
  text = titleset.text
  linearray = []
  text.each_line{|line| 
    time = nil
    title = nil
    if time_title = line.match(/([0-9]+)時([0-9]+)分[～~][　 ](.*)/) then
      time = {'hour' => time_title[1], 'min' => time_title[2]}
      title = time_title[3]
    elsif time_title = line.match(/^時間未定[　 ](.*)/) then
      title = time_title[1]
    end
    linearray.push({'time' => time, 'title' => title}) unless title.nil?
  }
  titlearray.push(linearray)
}

eventarray = []
dayarray.zip(titlearray){|day,titles|
  titles.each{|title|
    event = {'date' => day, 'time' => title['time'], 'title' => title['title'], 'end_time' => nil, 'uri' => url}
    # puts event
    eventarray.push(event)
    # puts "---"
  }
}
YAML.dump(eventarray, File.open('wiki.yaml', 'w'))
