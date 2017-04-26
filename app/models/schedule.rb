class Schedule < ApplicationRecord
  belongs_to :client

  attr_accessor :select

  def self.days
    [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  end

  def self.times
    [:morning, :afternoon, :evening]
  end

  def self.build
    days.map do |day|
      times.map do |time|
        Schedule.new(day: day.to_s, time: time.to_s)
      end
    end
  end
end
