xml.instruct!
xml.kml(
  'xmlns' => 'http://www.opengis.net/kml/2.2',
  'xmlns:gx' => 'http://www.google.com/kml/ext/2.2',
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.opengis.net/kml/2.2 http://schemas.opengis.net/kml/2.2.0/ogckml22.xsd http://www.google.com/kml/ext/2.2 http://code.google.com/apis/kml/schema/kml22gx.xsd'
) do
  xml.Document(id: "track-information") do
    xml.name "track-information"
    xml.Snippet
    xml.Folder(id: "FeatureLayer0") do
      xml.name "track-information"
      xml.Snippet
      xml.Placemark(id: "ID_#{@track.id.to_s}") do
        xml.name @track.id.to_s
        xml.Snippet
        xml.description do
          xml.cdata! "no description"
        end
        xml.MultiGeometry do
          xml.LineString do
            xml.extrude 0
            xml.altitudeMode 'clampedToGround'
            xml.coordinates ' ' + @track.points.map{|p| [p.lng, p.lat, p.alt||0].join(',')}.join(' ')
          end
        end
      end
    end
  end
end