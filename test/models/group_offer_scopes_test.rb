require 'test_helper'

class GroupOfferScopesTest < ActiveSupport::TestCase
  test 'active' do
    group_offer_active = create :group_offer, active: true
    group_offer_not_active = create :group_offer, active: false
    query = GroupOffer.active
    assert query.include? group_offer_active
    refute query.include? group_offer_not_active
  end

  test 'archived' do
    group_offer_active = create :group_offer, active: true
    group_offer_not_active = create :group_offer, active: false
    query = GroupOffer.archived
    refute query.include? group_offer_active
    assert query.include? group_offer_not_active
  end

  test 'in_department' do
    in_department = create :group_offer, department: create(:department)
    outside_department = create :group_offer
    query = GroupOffer.in_department
    assert query.include? in_department
    refute query.include? outside_department
  end

  test 'active_group_assignments_between' do
    started_within_no_end, _rest = create_group_offer_entity(nil, 40.days.ago, nil, 1)
    started_within_end_within, _rest = create_group_offer_entity(nil, 40.days.ago, 30.days.ago, 1)
    started_within_end_after, _rest = create_group_offer_entity(nil, 40.days.ago, 10.days.ago, 1)

    started_before_no_end, _rest = create_group_offer_entity(nil, 100.days.ago, nil, 1)
    started_after_no_end, _rest = create_group_offer_entity(nil, 10.days.ago, nil, 1)

    started_before_end_after, _rest = create_group_offer_entity(nil, 100.days.ago, 10.days.ago, 1)
    started_before_end_within, _rest = create_group_offer_entity(nil, 100.days.ago, 35.days.ago, 1)
    started_before_end_before, _rest = create_group_offer_entity(nil, 100.days.ago, 50.days.ago, 1)

    query = GroupOffer.active_group_assignments_between(45.days.ago, 30.days.ago)

    assert query.include? started_within_no_end
    assert query.include? started_within_end_within
    assert query.include? started_within_end_after
    assert query.include? started_before_no_end
    assert query.include? started_before_end_after
    assert query.include? started_before_end_within
    refute query.include? started_after_no_end
    refute query.include? started_before_end_before

    started_before_end_before.update(necessary_volunteers: started_before_end_before.necessary_volunteers + 1)
    create_group_assignments(started_before_end_before, 45.days.ago, 10.days.ago, create(:volunteer))

    query = GroupOffer.active_group_assignments_between(45.days.ago, 30.days.ago)

    assert query.include? started_before_end_before
  end

  test 'created_before' do
    created_after, _rest = create_group_offer_entity(nil, 40.days.ago, nil, 1)
    created_before, _rest = create_group_offer_entity(nil, 100.days.ago, 10.days.ago, 1)
    query = GroupOffer.created_before(50.days.ago)
    assert query.include? created_before
    refute query.include? created_after
  end

  def create_group_offer_entity(title, start_date, end_date, *volunteers)
    category = create :group_offer_category, category_name: "Category #{title}"
    group_offer = create_group_offer(title, volunteers.size, start_date, category)
    group_offer.update(created_at: start_date)
    if volunteers.first.is_a?(Integer)
      volunteers = Array.new(volunteers.first).map { create(:volunteer) }
    end
    group_assignments = create_group_assignments(group_offer, start_date, end_date, *volunteers)

    return [group_offer, category, group_assignments] unless title
    instance_variable_set("@category_#{title}", category)
    instance_variable_set("@group_ass_#{title}", group_assignments)
    [group_offer, category, group_assignments]
  end

  def create_group_assignments(group_offer, start_date, end_date, *volunteers)
    volunteers.map do |volunteer|
      g_assignment = GroupAssignment.new(group_offer: group_offer, volunteer: volunteer,
        period_start: start_date, period_end: end_date)
      g_assignment.save
      g_assignment
    end
  end

  def create_group_offer(title, volunteer_count, start_date, group_offer_category = nil)
    group_offer_category ||= create :group_offer_category
    go_title = title ? title : Faker::Simpsons.quote
    group_offer = create :group_offer, group_offer_category: group_offer_category, title: go_title,
      necessary_volunteers: volunteer_count
    group_offer.update(created_at: start_date)
    return group_offer unless title
    instance_variable_set("@group_offer_#{title}", group_offer)
    group_offer
  end
end
