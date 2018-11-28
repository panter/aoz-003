module NotificationHelper
  def notification_bubble(text, type)
    tag.div(class: "alert #{type} alert-dismissible", role: 'alert') do
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
