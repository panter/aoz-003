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

  def link_to_add_polymorphic_association(*args)
    name, f, association, html_options = *args
    html_options[:partial] = "#{association}/fields"
    link_to_add_association(name, f, association, html_options)
  end
end
