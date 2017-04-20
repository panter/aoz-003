User.find_or_create_by!(email: 'superadmin@example.com') do |user|
  user.password = 'asdfasdf'
  user.role = 'superadmin'
end

User.find_or_create_by!(email: 'social_worker@example.com') do |user|
  user.password = 'asdfasdf'
  user.role = 'social_worker'
end

User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'asdfasdf'
  user.role = 'admin'
end

User.all.each do |user|
  Profile.find_or_create_by!(user: user) do |profile|
    profile.first_name = user.role
    profile.last_name = user.role
    profile.user = user
  end

  Client.find_or_create_by!(
    firstname: "#{user.profile.first_name}'s Client",
    user: user
  ) do |client|
    client.firstname = "#{user.profile.first_name}'s Client"
    client.lastname = 'a lastname'
    client.user = user
  end
end
