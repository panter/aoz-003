class MakeBooleanFieldsDefaultFalse < ActiveRecord::Migration[5.1]
  def change
    with_options from: nil, to: false do |o|
      o.change_column_default :volunteers, :experience
      o.change_column_default :volunteers, :man
      o.change_column_default :volunteers, :woman
      o.change_column_default :volunteers, :family
      o.change_column_default :volunteers, :kid
      o.change_column_default :volunteers, :sport
      o.change_column_default :volunteers, :creative
      o.change_column_default :volunteers, :music
      o.change_column_default :volunteers, :culture
      o.change_column_default :volunteers, :training
      o.change_column_default :volunteers, :german_course
      o.change_column_default :volunteers, :teenagers
      o.change_column_default :volunteers, :children
      o.change_column_default :volunteers, :dancing
      o.change_column_default :volunteers, :health
      o.change_column_default :volunteers, :cooking
      o.change_column_default :volunteers, :excursions
      o.change_column_default :volunteers, :women
      o.change_column_default :volunteers, :unaccompanied
      o.change_column_default :volunteers, :zurich
      o.change_column_default :volunteers, :other_offer
    end
  end
end
