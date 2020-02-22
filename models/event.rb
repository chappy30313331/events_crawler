require 'active_record'

class Event < ActiveRecord::Base
  belongs_to :venue
  has_many :event_artists
  has_many :artists, through: :event_artists

  def self.calc_url_hash(url)
    Digest::MD5.hexdigest(url)
  end
end
