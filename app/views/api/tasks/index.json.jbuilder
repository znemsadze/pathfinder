json.tasks @tasks do |task|
  json.id task.id.to_s
  json.number task.number
  json.note task.note
  json.status task.status
  json.paths task.paths
  json.created_at task.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')
  json.destinations task.normal_destinations do |destination|
    json.id destination.id.to_s
    json.type destination.class.name
    json.name destination.name
  end
end