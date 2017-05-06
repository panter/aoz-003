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
    { t('gender.female') => 'female', t('gender.male') => 'male' }
  end

  def language_level_collection
    { t('client.language_level.native_speaker') => 'native_speaker',
      t('client.language_level.fluent') => 'fluent',
      t('client.language_level.good') => 'good',
      t('client.language_level.basic') => 'basic' }
  end

  def state_collection
    { t('state.registered') => 'registered', t('state.reserved') => 'reserved',
      t('state.active') => 'active', t('state.finished') => 'finished',
      t('state.rejected') => 'rejected' }
  end

  def role_collection
    { t('user.role.superadmin') => 'superadmin',
      t('user.role.admin') => 'admin',
      t('user.role.social_worker') => 'social_worker' }
  end

  def week
    [:monday, :tuesday, :wednesday, :thursday, :friday]
  end
end
