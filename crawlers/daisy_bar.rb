require_relative '../common'

venue = Venue.find_by!(name: '下北沢Daisy Bar')

uri = 'https://daisybar.jp/events/event/on/2020/02/'
doc = get_doc(uri)

doc.css('article.single-article').each do |area|
  event_url = URI.join(uri, "##{area.attribute('id').value}").to_s
  url_hash = Event.calc_url_hash(event_url)
  next if Event.where(url_hash: url_hash).any?

  date = Date.parse(area.at_css('div.single-date > div.h3').text)
  title = area.at_css('div.single-title > p.h4').text
  next if title.nil?

  thumbnail = area.at_css('img.attachment-artist')&.attribute('src')&.value
  image = thumbnail.nil? ? nil : area.at_css('img.attachment-artist').parent.attribute('href')&.value
  artists = area.at_css('div.artist > p').text.gsub(/food:|\(special thanks\)|\(O.A\)|【ONE MAN】|【TWO MAN】|【2MAN】|\(BAND SET\)|\+1 BAND|　…and more!!/, '').split(/[\n／]/)&.reject do |a|
    ['', ' ', ' ', '- LIVE -', '- DJ -', '【Bass / Vocal】', '【Drummers】', '【Gt / Cho】', 'and more!!!'].include?(a) || a.include?('キャンセル')
  end.compact.map(&:strip)
  next if artists.any? { |a| a.include?('OFFICIAL HP') }

  create_event_and_artists(venue: venue, title: title, date: date, url: event_url, url_hash: url_hash, thumbnail: thumbnail, image: image, artists: artists)
end
