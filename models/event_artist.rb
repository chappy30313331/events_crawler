require 'active_record'

class EventArtist < ActiveRecord::Base
  belongs_to :event
  belongs_to :artist
end