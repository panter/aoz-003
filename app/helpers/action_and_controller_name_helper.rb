module ActionAndControllerNameHelper
  def action_new?
    action_name == 'new' || action_name == 'create'
  end

  def action_index?
    action_name == 'index'
  end

  def action_show?
    action_name == 'show'
  end

  def action_edit?
    action_name == 'edit' || action_name == 'update'
  end

  def action_in?(*names)
    names.map(&:to_s).include? action_name
  end

  def controller_in?(*names)
    names.map(&:to_s).include? controller_name
  end
end
