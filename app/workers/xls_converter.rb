# -*- encoding : utf-8 -*-
class XLSConverter
  include Sidekiq::Worker

  def perform(type, path)
    sheet=Roo::Spreadsheet.open(path, extension: 'xlsx')
    case type
    when 'Objects::Line' then lines_converter(sheet)
    when 'Objects::Tower' then towers_converter(sheet)
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

  def towers_converter(sheet)
    (2..sheet.last_row).each do |row|
      id=sheet.cell('A',row) ; name=sheet.excelx_value('C',row).to_s ; category=sheet.cell('D', row)
      regionname=sheet.cell('E',row).to_s
      lat=sheet.cell('F',row).to_f; lng=sheet.cell('G',row).to_f
      description=sheet.cell('H',row)
      region=Region.where(name:regionname).first
      region=Region.create(name:regionname) unless region.present?
      tower=Objects::Tower.find(id)
      tower.name=name ; tower.region=region ; tower.category=category
      tower.lat=lat ; tower.lng=lng; tower.description=description
      tower.save
    end
  end
end
