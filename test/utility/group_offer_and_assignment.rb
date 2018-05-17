module GroupOfferAndAssignment
  def make_assignment(title: nil, start_date: nil, end_date: nil, client: nil, volunteer: nil)
    assignment = create(
      :assignment, period_start: start_date, period_end: end_date,
      client: client || create(:client),
      volunteer: volunteer || create(:volunteer)
    )
    assignment.update(created_at: start_date) if start_date
    return assignment unless title
    instance_variable_set("@#{title}", assignment)
  end

  def make_volunteer(title, *attributes)
    acceptance = attributes.is_a?(Hash) ? attributes[:acceptance] : 'accepted'
    volunteer = if acceptance && acceptance.to_s != 'accepted'
                  create :volunteer_with_user, *attributes
                else
                  create :volunteer, *attributes
                end
    return volunteer if title.nil?
    instance_variable_set("@#{title}", volunteer)
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

  def create_assignment_entity(title, volunteer, client, start_date, end_date = nil)
    volunteer = if volunteer == :volunteer_external
                  create :volunteer, external: true
                else
                  create volunteer
                end
    volunteer.update(created_at: start_date)
    client = create client, user: @user
    client.update(created_at: start_date)
    assignment = create_assignment(title && "a_#{title}", volunteer, client, start_date, end_date)
    assignment.update(created_at: start_date)
    return [volunteer, client, assignment] unless title
    instance_variable_set("@c_#{title}", client)
    instance_variable_set("@v_#{title}", volunteer)
  end

  def create_group_assignments(group_offer, start_date, end_date, *volunteers)
    group_offer.update(necessary_volunteers: volunteers.size)
    volunteers.map do |volunteer|
      g_assignment = GroupAssignment.new(group_offer: group_offer, volunteer: volunteer,
        period_start: start_date, period_end: end_date)
      g_assignment.save
      g_assignment
    end
  end

  def create_group_assignments_by_period(start_date = nil, end_date = nil)
    volunteer = create :volunteer
    volunteer.contact.update(first_name: FFaker::Name.unique.first_name)
    create_group_assignments(create(:group_offer), start_date, end_date, volunteer)
  end

  def create_group_offer(title, volunteer_count, start_date, group_offer_category = nil)
    group_offer_category ||= create :group_offer_category
    go_title = title ? title : FFaker::CheesyLingo.title
    group_offer = create :group_offer, group_offer_category: group_offer_category, title: go_title,
      necessary_volunteers: volunteer_count
    group_offer.update(created_at: start_date)
    return group_offer unless title
    instance_variable_set("@group_offer_#{title}", group_offer)
    group_offer
  end
end
