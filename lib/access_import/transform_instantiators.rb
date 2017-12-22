module TransformInstantiators
  def assignment_transform
    @assignment_transform ||= AssignmentTransform.new(self, @begleitete, @freiwilligen_einsaetze)
  end

  def client_transform
    @client_transform ||= ClientTransform.new(self, @begleitete, @haupt_person, @familien_rollen,
      @personen_rolle)
  end

  def department_transform
    @department_transform ||= DepartmentTransform.new(self, @einsatz_orte)
  end

  def einsatz_transform
    @einsatz_transform ||= EinsatzTransform.new(self, @freiwilligen_einsaetze, @personen_rolle)
  end

  def group_offer_transform
    @group_offer_transform ||= GroupOfferTransform.new(self, @freiwilligen_einsaetze, @rollen)
  end

  def group_assignment_transform
    @group_assignment_transform ||= GroupAssignmentTransform.new(self, @begleitete,
      @freiwilligen_einsaetze, @personen_rolle, @haupt_person)
  end

  def journal_transform
    @journal_transform ||= JournalTransform.new(self, @freiwilligen_einsaetze, @journale, @personen_rolle, @haupt_person)
  end

  def kurs_transform
    @kurs_transform ||= KursTransform.new(self, @kurse, @begleitete, @haupt_person, @familien_rollen,
      @personen_rolle, @kursarten, @freiwilligen_einsaetze, @einsatz_orte)
  end

  def kursart_transform
    @kursart_transform ||= KursartTransform.new(self, @kursarten)
  end

  def volunteer_transform
    @volunteer_transform ||= VolunteerTransform.new(self, @haupt_person, @personen_rolle)
  end
end