# require "sti_preload"

class TbpView < ApplicationRecord
  include StiPreload # Only in the root class.
  self.abstract_class = true

  def self.using(connection)
    if Rails.env.test?
      self #super('pg')
    else
      super(connection)
    end
  end

  def readonly?
    if Rails.env.production?
      true
    else
      super
    end
  end

  def delete
    raise ActiveRecord::ReadOnlyRecord
  end

  def delete_all
    raise ActiveRecord::ReadOnlyRecord
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end

  def self.to_csv(options = {force_quotes: true})
    CSV.generate(options) do |csv|
      csv << column_names.collect { |colname| I18n.t("#{self.name.underscore}.#{colname}") }
      all.each do |thing|
        csv << thing.attributes.values_at(*column_names).collect {|c| '="'+c.to_s+'"'}
      end
    end
  end

end

