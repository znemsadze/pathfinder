# -*- encoding : utf-8 -*-
class XLSConverter
  include Sidekiq::Worker

  def perform(type, path)
    sheet=Roo::Spreadsheet.open(path, extension: 'xlsx')
    case type
    when 'Objects::Line' then lines_converter(sheet)
    end
  end

  private

  def lines_converter(sheet)
    (2..sheet.last_row).each do |row|
      id=sheet.cell('A',row) ; name=sheet.cell('C',row) ; regionname=sheet.cell('D',row)
      region=Region.where(name:regionname).first
      region=Region.create(name:regionname) unless region.present?
      line = Objects::Line.find(id)
      line.name = name ; line.region = region ; line.save
    end
  end
end
