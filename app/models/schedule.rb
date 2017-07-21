class Schedule < ApplicationRecord
  belongs_to :scheduleable, polymorphic: true, optional: true

  attr_accessor :select

  DAYS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday].freeze
  TIMES = ['morning', 'afternoon', 'evening'].freeze
  CORRECT_SIZE = 7 * TIMES.size

  def self.build
    DAYS.map do |day|
      TIMES.map do |time|
        Schedule.new(
          day: day,
          time: time
        )
      end
    end
  end
end
