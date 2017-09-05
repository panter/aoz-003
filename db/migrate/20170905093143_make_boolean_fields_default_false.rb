class MakeBooleanFieldsDefaultFalse < ActiveRecord::Migration[5.1]
  def change
    change_column_default :volunteers, :experience, from: nil, to: false
    change_column_default :volunteers, :man, from: nil, to: false
    change_column_default :volunteers, :woman, from: nil, to: false
    change_column_default :volunteers, :family, from: nil, to: false
    change_column_default :volunteers, :kid, from: nil, to: false
    change_column_default :volunteers, :sport, from: nil, to: false
    change_column_default :volunteers, :creative, from: nil, to: false
    change_column_default :volunteers, :music, from: nil, to: false
    change_column_default :volunteers, :culture, from: nil, to: false
    change_column_default :volunteers, :training, from: nil, to: false
    change_column_default :volunteers, :german_course, from: nil, to: false
    change_column_default :volunteers, :teenagers, from: nil, to: false
    change_column_default :volunteers, :children, from: nil, to: false
    change_column_default :volunteers, :dancing, from: nil, to: false
    change_column_default :volunteers, :health, from: nil, to: false
    change_column_default :volunteers, :cooking, from: nil, to: false
    change_column_default :volunteers, :excursions, from: nil, to: false
    change_column_default :volunteers, :women, from: nil, to: false
    change_column_default :volunteers, :unaccompanied, from: nil, to: false
    change_column_default :volunteers, :zurich, from: nil, to: false
    change_column_default :volunteers, :other_offer, from: nil, to: false
  end
end
