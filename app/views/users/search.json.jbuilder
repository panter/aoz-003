json.array!(@users) do |user|
  json.id user.id
  json.label user.full_name + " – #{t("role.#{user.role}")}"
  json.value user.full_name
end
