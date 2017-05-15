module ApplicationHelper
  def permit_collection
    [:L, :B]
  end

  def gender_collection
    [:female, :male]
  end

  def language_level_collection
    [:native_speaker, :fluent, :good, :basic]
  end

  def state_collection
    [:registered, :reserved, :active, :finished, :rejected]
  end

  def week(with_weekend = false)
    if with_weekend
      [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    else
      [:monday, :tuesday, :wednesday, :thursday, :friday]
    end
  end
end
