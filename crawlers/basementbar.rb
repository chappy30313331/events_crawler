require_relative '../common'

venue = Venue.find(1)

event_urls = []
1.step do |n|
  uri = "https://toos.co.jp/basementbar/wp-admin/admin-ajax.php?action=eventorganiser-posterboard&page=#{n}&query%5Bposts_per_page%5D=10&query%5Bevent_start_after%5D=today"
  sleep(1)
  json = JSON.parse(URI.open(uri) { |f| f.read })
  break if json.length.zero?
  event_urls.concat(json.map { |j| j['event_permalink'] })
end

event_urls.each do |event_url|
  url_hash = Event.calc_url_hash(event_url)
  next if Event.where(url_hash: url_hash).any?

  doc = get_doc(uri)

  title = doc.at_css('div.main_title').text
  date = Date.parse(doc.at_css('div.date').text)
  thumbnail_node = doc.at_css('div.entry-content img')
  thumbnail = thumbnail_node&.attribute('src')&.value
  image = thumbnail_node&.parent&.attribute('href')&.value
  artists = doc.css('div.box div.detail').map { |a| a.text.split("\n") }.flatten

  create_event_and_artists(venue: venue, title: title, date: date, url: event_url, url_hash: url_hash, thumbnail: thumbnail_node, image: image, artists: artists)
end
