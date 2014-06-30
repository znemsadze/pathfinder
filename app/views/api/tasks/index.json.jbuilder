json.array! @tasks do |task|
  json.id task.id.to_s
  json.number task.number
  json.status task.status
  json.paths task.paths
  json.destinations task.normal_destinations do |destination|
    json.id destination.id.to_s
    json.type destination.class.name
    json.name destination.name
  end
end