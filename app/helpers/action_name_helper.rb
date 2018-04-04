module ActionNameHelper
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
end
