module ApplicationHelper

  def permit_collection
    { 'L' => 'l', 'B' => 'b' }
  end

  def gender_collection
    { 'female' => 'f', 'male' => 'm' }
  end

  def language_level_collection
    { 'native speaker' => 'native', 'fluent' => 'fluent', 'good' => 'good',
      'basic' => 'basic' }
  end

  def state_collection
    { 'registered' => 'registered', 'reserved' => 'reserved',
      'active' => 'active', 'finished' => 'finished', 'rejected' => 'rejected'}
  end
end
