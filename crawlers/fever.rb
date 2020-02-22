require_relative '../common'

venue = Venue.find(5)

uri = 'https://www.fever-popo.com/schedule/2020/02/'
doc = get_doc(uri)

doc.css('div.hentry').each do |area|
  event_url = URI.join(uri, "##{area.attribute('id').value}").to_s
  url_hash = Event.calc_url_hash(event_url)
  next if Event.where(url_hash: url_hash).any?

  date_and_title = area.at_css('h2.eventtitle').text
  date, title = /^(\d{2}\.\d{2}\.\d{2}) \(\w{3}\)[[:space:]]+(.*)$/.match(date_and_title).to_a[1..2]
  next if title.nil?

  date = Date.parse(date)
  thumbnail = area.at_css('span.mt-enclosure-image > a > img')&.attribute('src')&.value
  image = thumbnail.nil? ? nil : "http://www.fever-popo.com/#{/.*\/(\d{6}).*\.jpg/.match(thumbnail).to_a.last}.jpg"
  artists = area.css('div.asset-body > p').map { |a| a.text.split("\n").map { |b| b =~ /^[^\(（【]+[／\/][^\)）】]+$/ ? b.split(/[／\/]/) : b } }&.flatten&.reject do |a|
    ['', ' ', ' ', '- LIVE -', '- DJ -', '【Bass / Vocal】', '【Drummers】', '【Gt / Cho】', 'and more!!!'].include?(a)
  end.compact.map(&:strip)
  next if artists.any? { |a| a.include?('キャンセル') }

  create_event_and_artists(venue: venue, title: title, date: date, url: event_url, url_hash: url_hash, thumbnail: thumbnail_node, image: image, artists: artists)
end
