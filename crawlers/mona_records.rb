require_relative '../common'

venue = Venue.find(3)

uri = 'http://www.mona-records.com/live/2020/02/'
doc = get_doc(uri)

doc.css('div.live-menu-box').each do |area|
  event_url = area.at_css('p.live-look-details > a').attribute('href').value
  url_hash = Event.calc_url_hash(event_url)
  next if Event.where(url_hash: url_hash).any?

  title_node = area.at_css('div.live-monthly > p.live-title-monthly')
  title = title_node&.text
  next if title.nil?
  
  date = Date.parse(area.at_css('p.live-date'))
  image = area.at_css('div.live-monthly > a > img')&.attribute('src')&.value
  artists = title_node.next.next.text.sub("【出演】\u00A0", '').split(' / ')

  create_event_and_artists(venue: venue, title: title, date: date, url: event_url, url_hash: url_hash, thumbnail: thumbnail_node, image: image, artists: artists)
end
