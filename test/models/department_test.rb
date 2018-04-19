require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def setup
    @department = build :department
  end

  test 'department is valid' do
    assert @department.valid?
  end

  test 'contact relation is build automatically' do
    new_department = Department.new
    assert new_department.contact.present?
  end

  test 'orders by contact last_name' do
    # generate a ordered sequence of departments
    sequence = ('0'..'9').to_a + ('a'..'z').to_a
    sequence.each { |l| create(:department).contact.update last_name: "#{l} Department" }

    Department.name_asc.each_with_index do |d, i|
      assert_equal "#{sequence[i]} Department", d.contact.last_name
    end

    Department.name_desc.each_with_index do |d, i|
      assert_equal "#{sequence.reverse[i]} Department", d.contact.last_name
    end
  end
end
