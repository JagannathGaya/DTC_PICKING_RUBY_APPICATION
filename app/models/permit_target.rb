class PermitTarget
  attr_accessor :targets
  @@targets = []

  def initialize
  end

  def self.set_permit_targets
    self.clear
    Rails.configuration.permit_targets.each do |target|
      self.add(target[:controller], target[:method], target[:name])
    end
  end

  def self.add(controller, method, name)
    @@targets << [controller, method, name]
  end

  def self.list
    @@targets
  end

  def self.find(controller , method = 'index')
    target_rows = @@targets.select { |row| row[0] == controller && row[1] == method }
    #  puts "PermitTarget find #{target_rows.inspect}"
    return target_rows[0][2] if target_rows[0]
  end

  def self.reports
    @@targets.map { |row| row[2] }
  end

  def self.clear
    @@targets = []
  end

  def self.list_for_maxima
    makers = Maker.all.pluck(:name).uniq
    (@@targets.map { |row|  ( ['index','new'].include?(row[1]) ? 'SCREEN: ' +  row[2] : row[2]) } + makers.map { |m| 'SUBSCR: ' + m}).sort
  end

  self.set_permit_targets # LJK sort of a class-level initialize ...

end