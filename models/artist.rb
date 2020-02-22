require 'active_record'

class Artist < ActiveRecord::Base
  has_many :event_artists
  has_many :events, through: :event_artists
end
