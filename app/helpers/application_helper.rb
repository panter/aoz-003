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

  # volunteer collections
  def duration_collection
    [:short, :long]
  end

  def region_collection
    [:city, :region, :canton]
  end

  def single_accompaniment
    [:man, :woman, :family, :kid]
  end

  def group_accompaniment
    [:sport, :creative, :music, :culture, :training, :german_course]
  end
end
