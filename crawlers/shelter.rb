require_relative '../common'

venue = Venue.find(4)

uri = 'http://www.loft-prj.co.jp/schedule/shelter'
doc = get_doc(uri)

doc.css('table.timetable tr').each do |area|
  event_url = area.at_css('td.event_box > div.event > h3 > a').attribute('href').value
  url_hash = Event.calc_url_hash(event_url)
  next if Event.where(url_hash: url_hash).any?

  title = area.at_css('td.event_box > div.event > h3 > a').text
  next if title.nil?

  date = Date.parse(area.at_css('th.day > p'))
  thumbnail = area.at_css('td.event_box > div.event > div.imgBlock > img')&.attribute('src')&.value
  image = if image_srcset = area.at_css('td.event_box > div.event > div.imgBlock > img')&.attribute('srcset')&.value
    image_srcset.split(', ').last.split(' ').first
  else
    nil
  end
  artists = area.at_css('td.event_box > div.event > p.month_content').text.split("\n").reject do |a|
    ['', ' ', ' ', 'and more', '【DJ】', '【LIVE】', '<SHOP>'].include?(a)
  end.map(&:strip)

  create_event_and_artists(venue: venue, title: title, date: date, url: event_url, url_hash: url_hash, thumbnail: thumbnail_node, image: image, artists: artists)
end
