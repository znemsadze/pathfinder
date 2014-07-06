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
    json.lat destination.lat
    json.lng destination.lng
  end
  json.tracking task.tracking_paths do |tracking|
    json.id tracking.id.to_s
    json.open tracking.open
    json.points tracking.points do |point|
      json.lat point.lat
      json.lng point.lng
    end
  end
end