module NotificationHelper
  def notification_warning_bubble(text)
    tag.div(class: 'alert alert-warning alert-dismissible', role: 'alert') do
      concat notification_close_button
      concat raw(text)
    end
  end

  def notification_close_button(text = nil)
    tag.button(
      class: 'close', aria: { label: 'Schliessen' }, data: { dismiss: 'alert' }, type: 'button'
    ) do
      if text.present?
        concat text
      else
        tag.span('x', aria: { hidden: 'true' })
      end
    end
  end
end
