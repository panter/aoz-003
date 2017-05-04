module ApplicationHelper
  def daynames(whole_week = false)
    if whole_week
      [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    else
      [:monday, :tuesday, :wednesday, :thursday, :friday]
    end
  end

  def permit_collection
    { 'L' => 'L', 'B' => 'B' }
  end

  def gender_collection
    { t('gender.female') => 'Female', t('gender.male') => 'Male' }
  end

  def language_level_collection
    { t('language_level.native_speaker') => 'Native speaker',
      t('language_level.fluent') => 'Fluent',
      t('language_level.good') => 'Good',
      t('language_level.basic') => 'Basic' }
  end

  def state_collection
    { t('state.registered') => 'Registered', t('state.reserved') => 'Reserved',
      t('state.active') => 'Active', t('state.finished') => 'Finished',
      t('state.rejected') => 'Rejected' }
  end

  def week
    [:monday, :tuesday, :wednesday, :thursday, :friday]
  end
end
