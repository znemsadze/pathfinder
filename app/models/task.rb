# -*- encoding : utf-8 -*-
class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include Kml

  START = 0
  CANCELED = 1
  IN_PROGRESS = 2
  COMPLETED = 10

  belongs_to :assignee, class_name: 'Sys::User'
  field :destinations, type: Array
  field :paths, type: Array
  field :number, type: Integer
  field :note, type: String
  field :status, type: Integer, default: START
  has_many :tracking_paths, class_name: 'Tracking::Path'
  has_many :notes, class_name: 'Objects::Note'
  before_create :on_before_create

  def normal_destinations
    self.destinations.map do |dest|
      dest['type'].constantize.find(dest['id'])
    end
  end

  def self.current_task(user)
    Task.where(assignee: user, status: IN_PROGRESS).first
  end

  def self.open_tasks
    Task.where(:status.in => [START, IN_PROGRESS])
  end

  def can_delete?; self.start? end
  def can_begin?; self.start? end
  def can_complete?; self.in_progress? end
  def can_cancel?; self.start? or self.in_progress? end

  def start?; self.status == START end
  def in_progress?; self.status == IN_PROGRESS end
  def completed?; self.status == COMPLETED end
  def canceled?; self.status == CANCELED end

  def begin
    if self.start?
      raise 'დახურეთ ყველა დავალება' if Task.where(assignee: self.assignee, status: IN_PROGRESS).any?
      self.status=IN_PROGRESS ; self.save
      Tracking::Path.close_paths(self.assignee)
    end
  end

  def complete
    if self.in_progress?
      self.status = COMPLETED ; self.save
      Tracking::Path.close_paths(self.assignee)
    end
  end

  def cancel
    if self.in_progress? or self.start?
      self.status = CANCELED ; self.save
      Tracking::Path.close_paths(self.assignee)
    end
  end

  def status_icon
    case self.status
    when IN_PROGRESS then '/icons/status_in_progress.png'
    when COMPLETED then '/icons/status_completed.png'
    when CANCELED then '/icons/status_canceled.png'
    else '/icons/status_start.png'
    end
  end

  def status_name
    case self.status
    when IN_PROGRESS then I18n.t('models.task.statuses.in_progress')
    when COMPLETED then I18n.t('models.task.statuses.completed')
    when CANCELED then I18n.t('models.task.statuses.canceled')
    else I18n.t('models.task.statuses.start')
    end
  end

  def to_kml
    kml_document do |xml|
      xml.Document(id: "task-information") do |xml|
        xml.name "task-information"
        # xml.Snippet
        xml.Folder(id: "FeatureLayer0") do
          xml.name "task-information"
          xml.Snippet
          self.tracking_paths.each { |path| path.to_kml(xml) }
        end
      end
    end
  end

  private
  def on_before_create
    last = Task.last
    if last.blank? then self.number = 1
    else self.number = last.number + 1 end
    true
  end
end
