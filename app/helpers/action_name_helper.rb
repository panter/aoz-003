module ActionNameHelper
  def action_new?
    action_name == 'new'
  end

  def action_index?
    action_name == 'index'
  end

  def action_show?
    action_name == 'show'
  end

  def action_edit?
    action_name == 'edit'
  end
end
