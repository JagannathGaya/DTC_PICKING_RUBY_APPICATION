# require "sti_preload"

class TbpUvw < ApplicationRecord
  include StiPreload # Only in the root class.
  self.abstract_class = true

  # Note that AR objects that inherit from this must have an id column in order to be tested using rspec.
  # You do not need the id column in the oracle uvw def itself, just in the create statement for the test
  # postgreSQL DB table definition
  # side effect: do not use the find method, always use where (not really significant since the uvws are
  # exclusively used for inserts)

  def self.using(connection)
    if Rails.env.test?
      self #super('pg')
    else
      super(connection)
    end
  end

  def self.to_csv(options = { force_quotes: false })
    CSV.generate(options) do |csv|
      csv << download_columns.collect { |colname| I18n.t("#{self.name.underscore}.#{colname}") }
      all.each do |thing|
        csv << thing.attributes.values_at(*download_columns).collect { |c| ['BigDecimal', 'Fixnum', 'NilClass'].include?(c.class.to_s) || options[:force_quotes] ? c : '="' + c.to_s + '"' }
      end
    end
  end

  def self.to_xml(options = {})
    super(options.merge({ except: self::EXCLUDE_COLUMNS }))
  end

  def self.download_columns
    return self.column_names unless self.const_defined?('EXCLUDE_COLUMNS')
    self.column_names - self::EXCLUDE_COLUMNS
  end


end

