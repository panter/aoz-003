json.array!(@users) do |user|
  json.data do
    json.category t("role.#{user.role}")
  end
  json.value "#{user.full_name}; #{user.email} - #{t("role.#{user.role}")}"
end
