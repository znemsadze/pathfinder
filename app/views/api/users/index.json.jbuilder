json.array! @users do |user|
  json.id user.id.to_s
  json.username "#{user.username} (#{user.full_name})"
end