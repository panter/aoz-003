module ApplicationHelper
  def permit_collection
    [:L, :B]
  end

  def week(with_weekend = false)
    if with_weekend
      [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    else
      [:monday, :tuesday, :wednesday, :thursday, :friday]
    end
  end

  def single_col_xs(inside, cols = 12)
    content_tag :div, class: 'row' do
      content_tag :div, class: "col-xs-#{cols}" do
        inside
      end
    end
  end

  def simple_error_notice(f)
    single_col_xs f.error_notification if f.error_notification.present?
  end

  def link_to_add_polymorphic_association(*args)
    name, f, association, html_options = *args
    html_options[:partial] = "#{association}/fields"
    link_to_add_association(name, f, association, html_options)
  end
end
