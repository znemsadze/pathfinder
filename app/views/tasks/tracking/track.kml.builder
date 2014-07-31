xml.instruct!
xml.kml(
  'xmlns' => 'http://www.opengis.net/kml/2.2',
  'xmlns:gx' => 'http://www.google.com/kml/ext/2.2',
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.opengis.net/kml/2.2 http://schemas.opengis.net/kml/2.2.0/ogckml22.xsd http://www.google.com/kml/ext/2.2 http://code.google.com/apis/kml/schema/kml22gx.xsd'
) do
  # xml.Document(id: "track-information") do
  #   xml.name "track-information"
  #   xml.Snippet
  #   xml.Folder(id: "FeatureLayer0") do
  #     xml.name "track-information"
  #     xml.Snippet
  xml << render(partial: '/tasks/track', locals: { track: @track })
  #   end
  # end
end