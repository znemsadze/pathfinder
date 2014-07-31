xml.Placemark(id: "ID_#{track.id.to_s}") do
  xml.name track.id.to_s
  xml.Snippet
  xml.description do
    xml.cdata! "no description"
  end
  xml.MultiGeometry do
    xml.LineString do
      xml.extrude 0
      xml.altitudeMode 'clampedToGround'
      xml.coordinates ' ' + track.points.map{|p| [p.lng, p.lat, p.alt||0].join(',')}.join(' ')
    end
  end
end