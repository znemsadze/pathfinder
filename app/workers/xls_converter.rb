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

  def get_region(regionname)
    region=Region.where(name:regionname).first
    region=Region.create(name:regionname) unless region.present?
    region
  end

  def lines_converter(sheet)
    (2..sheet.last_row).each do |row|
      id=sheet.cell('A',row) ; name=sheet.cell('C',row) ; regionname=sheet.cell('D',row)
      region = get_region(regionname)
      line = Objects::Line.find(id)
      line.name = name ; line.region = region ; line.save
    end
  end

  def towers_converter(sheet)
    (2..sheet.last_row).each do |row|
      id = sheet.cell('A',row) ; tower = Objects::Tower.find(id)
      name = sheet.excelx_value('B',row).to_s ; tower.name = name
      category=sheet.cell('C', row) ; tower.category = category
      regionname = sheet.cell('D',row).to_s ; tower.region = get_region(regionname)
      description=sheet.cell('E',row) ; tower.description = description
      tower.save
    end
  end
end
