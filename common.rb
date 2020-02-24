require 'digest/md5'
require 'json'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'dotenv/load'
require 'active_record'
require 'wareki'
require_relative './models/artist'
require_relative './models/event'
require_relative './models/venue'
require_relative './models/event_artist'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  database: ENV['DB_DATABASE'],
  host: ENV['DB_HOST'],
  username: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD']
)
Time.zone_default = Time.find_zone! 'Tokyo'
ActiveRecord::Base.default_timezone = :local

def get_doc(uri)
  sleep(1)
  html = URI.open(uri) { |f| f.read }
  Nokogiri::HTML.parse(html)
end

def create_event_and_artists(venue:, title:, date:, url:, url_hash:, thumbnail:, image:, artists:)
  begin
    event = Event.create(venue_id: venue.id, title: title, date: date, url: url, url_hash: url_hash, thumbnail: thumbnail, image: image)
    artists.each do |artist_name|
      artist = Artist.find_or_create_by(name: artist_name)
      artist.events << event
    end
  rescue ActiveRecord::ValueTooLong => e
    puts "Venue: #{venue.name}"
    puts "URL: #{url}"
    puts e.message
    puts e.backtrace
  end
end
