module SemesterProcessHelper

  def sort_volunteers
    @semester_process.new_semester_process_volunteers.sort do |spv1, spv2|
      spv1.volunteer.contact.full_name <=> spv2.volunteer.contact.full_name
    end
  end

end
