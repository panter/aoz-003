module MakeNotice
  extend ActiveSupport::Concern

  included do
    def t_model
      controller_name.singularize.classify.constantize.model_name.human
    end

    def make_notice
      {
        notice: t("crud.c_action.#{action_name}", model: t_model)
      }
    end
  end
end
