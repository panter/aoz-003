
Faker::Config.locale = 'de'

def random_relation
  [
    'brother', 'sister', 'mother', 'father', 'foster-mother',
    'foster-father', 'friend', 'neighbour', 'cousin', 'uncle', 'aunt',
    'son', 'doughter', 'newphew', 'niece'
  ].sample
end

def make_relatives
  Array.new(2).map do
    Relative.new do |relative|
      # relative.first_name = Faker::Name.first_name
      # relative.last_name = Faker::Name.last_name
      relative.relation = random_relation
      # relative.date_of_birth = Faker::Date.birthday(18, 65)
    end
  end
end

def make_lang_skills
  Array.new(3).map do
    LanguageSkill.new do |l|
      l.language = I18nData.languages.to_a.sample[0]
      l.level = LanguageSkill.language_level_collection.sample
    end
  end
end

def make_schedule
  Schedule.build.each do |day|
    day.each do |time|
      time.available = [true, false].sample
    end
  end
end

User.role_collection.each do |role|
  User.find_or_create_by!(email: "#{role}@example.com") do |user|
    user.password = 'asdfasdf'
    user.role = role
    # user.profile = Profile.new do |profile|
    #   # profile.first_name = Faker::Name.first_name
    #   # profile.last_name = Faker::Name.last_name
    #   # profile.phone = Faker::PhoneNumber.phone_number
    #   # profile.address = Faker::Address.street_address
    #   # profile.profession = Faker::Company.profession
    #   # [:monday, :tuesday, :wednesday, :thursday, :friday].each do |day|
    #   #   profile[day] = [true, false].sample
    #   # end
    # end
  end
end

User.where(role: ['superadmin', 'social_worker']).each do |user|
  next if user.clients.count > 1
  user.clients = Array.new(4).map do
    Client.new do |client|
      client.state = 'registered'
      client.person = Person.new do |p|
        p.first_name = Faker::Name.first_name
        p.last_name = Faker::Name.last_name
        p.gender = ['male', 'female'].sample
        p.contact = Contact.new do |c|
          c.street = Faker::Address.street_address
          c.postal_code = Faker::Address.zip_code
          c.city = Faker::Address.city
          c.contact_emails = Array.new(3).map do
            ContactEmail.new do |email|
              email.body = Faker::Internet.email
              email.label = ContactEmail.label_collection.sample
            end
          end
          c.contact_phones = Array.new(3).map do
            ContactPhone.new do |phone|
              phone.body = Faker::PhoneNumber.phone_number
              phone.label = ContactPhone.label_collection.sample
            end
          end
        end
      end
      # client.contact = Contact.new do |c|
      #   c.first_name = Faker::Name.first_name
      #   c.last_name = Faker::Name.last_name
      #   c.gender = ['male', 'female'].sample

      # end
      # client.date_of_birth = Faker::Date.birthday(18, 65)
      # client.nationality = ISO3166::Country.codes.sample
      # client.relatives = make_relatives
      # client.language_skills = make_lang_skills
      # client.schedules << make_schedule
    end
  end
  user.save
end

if Department.count < 1
  department = Department.new do |d|
    d.contact = Contact.new do |c|
      c.name = 'Bogus Department'
      c.street = Faker::Address.street_address
      c.postal_code = Faker::Address.zip_code
      c.city = Faker::Address.city
      c.contact_emails = Array.new(3).map do
        ContactEmail.new do |email|
          email.body = Faker::Internet.email
          email.label = ContactEmail.label_collection.sample
        end
      end
      c.contact_phones = Array.new(3).map do
        ContactPhone.new do |phone|
          phone.body = Faker::PhoneNumber.phone_number
          phone.label = ContactPhone.label_collection.sample
        end
      end
    end
    d.user.push User.find_by(role: 'department_manager')
  end
  department.save!
end

Volunteer.state_collection.each do |state|
  # Volunteer.find_or_create_by!(email: "volunteer_#{state}@example.com", state: state) do |v|
  #   # v.first_name = Faker::Name.first_name
  #   # v.last_name = Faker::Name.last_name
  #   # v.date_of_birth = Faker::Date.birthday(18, 75)
  #   # v.zip = Faker::Address.zip_code
  #   # v.city = Faker::Address.city
  #   # v.street = Faker::Address.street_address
  #   # v.email = Faker::Internet.email
  #   # v.phone = Faker::PhoneNumber.phone_number
  #   # v.profession = Faker::Company.profession
  #   # v.gender = ['male', 'female'].sample
  #   [:experience, :man, :woman, :family, :kid, :sport, :creative, :music,
  #    :culture, :training, :german_course, :adults, :teenagers, :children].each do |bool_attr|
  #     v[bool_attr] = [true, false].sample
  #   end
  #   [:nationality, :additional_nationality].each { |n| v[n] = ISO3166::Country.codes.sample }
  #   v.education = "#{Faker::Educator.secondary_school}, #{Faker::Educator.university}"
  #   [:motivation, :expectations, :strengths, :interests].each do |attribute|
  #     v[attribute] = Faker::Lorem.sentence(rand(2..5))
  #   end
  #   v.skills = "#{Faker::Job.key_skill}, #{Faker::Job.key_skill}, #{Faker::Job.key_skill}"
  #   v.duration = ['long', 'short'].sample
  #   v.region = ['city', 'region', 'canton'].sample
  #   # v.language_skills = make_lang_skills
  #   # v.schedules << make_schedule
  # end
end
