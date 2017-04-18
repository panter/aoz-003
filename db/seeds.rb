User.find_or_create_by!(email: 'superadmin@example.com') do |user|
  user.password = 'asdfasdf'
  user.role = 'superadmin'
end
