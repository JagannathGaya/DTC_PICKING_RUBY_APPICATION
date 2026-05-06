# require "sti_preload"

class TbpLov < TbpView
  include StiPreload # Only in the root class.
  self.abstract_class = true
  #
  #  CONVENTION: ALL models subclassed from here MUST have two columns named LOV_ID and LOV_LABEL in underlying table or view
  #
  EXCLUDE_COLUMNS = []
  EXCLUDE_FILTERS = ['id']

  scope :lov, -> { order(:lov_sort).pluck(:lov_id, :lov_label) }

  def self.lov_all
    self.lov.uniq.unshift(['All', 'All Rows'])
  end

  def self.form_lov
    self.lov.uniq.map {|s| [s[1], s[0]]}
  end

  def self.form_lov_all
    self.lov.uniq.map {|s| [s[1], s[0]]}.unshift(['All', '@'])
  end

end

