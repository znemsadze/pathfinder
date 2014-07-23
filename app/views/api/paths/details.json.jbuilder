json.array! @types do |type|
  json.id type.id.to_s
  json.name type.name
  json.order_by type.order_by
  json.surfaces do
    json.array! type.surfaces do |surface|
      json.id surface.id.to_s
      json.name surface.name
      json.order_by surface.order_by
      json.details do
        json.array! surface.details do |detail|
          json.id detail.id.to_s
          json.name detail.name
          json.order_by detail.order_by
        end
      end
    end
  end
end