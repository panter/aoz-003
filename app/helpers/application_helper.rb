module ApplicationHelper
  def permit_collection
    { 'L' => 'L', 'B' => 'B' }
  end

  def gender_collection
    { 'Female' => 'Female', 'Male' => 'Male' }
  end

  def language_level_collection
    { 'Native speaker' => 'Native speaker', 'Fluent' => 'Fluent', 'Good' => 'Good',
      'Basic' => 'Basic' }
  end

  def state_collection
    { 'Registered' => 'Registered', 'Reserved' => 'Reserved',
      'Active' => 'Active', 'Finished' => 'Finished', 'Rejected' => 'Rejected' }
  end

  def week
    [:monday, :tuesday, :wednesday, :thursday, :friday]
  end
end
