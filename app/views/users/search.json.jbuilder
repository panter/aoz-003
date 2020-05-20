json.array!(@users) do |user|
  json.data do
    json.category t("role.#{user.role}")
    json.search user.full_name
  end
  json.value "#{user.full_name}; #{user.email} - #{t("role.#{user.role}")}"
end
