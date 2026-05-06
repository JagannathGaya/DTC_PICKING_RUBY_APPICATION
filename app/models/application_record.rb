# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :filter_by_column, ->(column, filter, all) {
    where(column => filter) if !filter.blank? && (all.blank? || filter != all)
  }

  scope :filter_by_qty_gt_than, ->(column, value_filter) {
    where("#{column} > ?", value_filter) unless value_filter.blank?
  }

  # scope :filter_by_qty, ->(column, filter) {
  #   where(column + filter) if filter && %w[>0 =0 !=0 <0].include?(filter)
  # }

  scope :filter_by_specific_qty, ->(column, type_filter, value_filter) {
    where(column.to_s.upcase + type_filter + value_filter) if !type_filter.blank? &&
        %w[> = <].include?(type_filter) && !value_filter.blank?
  }

  # scope :filter_by_column_range, ->(column, filter1, filter2) {
  #   if filter2.blank? || filter2 == t(:all)
  #     where(column => filter1) if !filter1.blank? && filter1 != t(:all)
  #   else
  #     where("#{column} between ? and ?", filter1.upcase, filter2.upcase) if filter1 != t(:all)
  #   end
  # }

  # scope :filter_date_column, ->(column, filter) {
  #   where("trunc(#{column}) = to_date(?,'dd-mon-yy')", filter.upcase) unless filter.blank?
  # }

  # scope :filter_ora_date_range, ->(column, filter1, filter2) {
  #   if filter1.blank?
  #     where("trunc(#{column}) = to_date(?,'DD-MON-YY')", filter2.upcase) unless filter2.blank?
  #   else
  #     where("trunc(#{column}) between to_date(?,'DD-MON-YY') and to_date(?,'DD-MON-YY')",
  #           filter1.upcase, filter2.upcase) unless filter2.blank?
  #   end
  # }

  scope :filter_pg_date_range, ->(column, filter1, filter2) {
    if filter1.blank?
      where("trunc(#{column}) = to_date(?,'DD-MON-YY')", filter2.upcase) unless filter2.blank?
    else
      where("#{column} between to_date(?,'DD-MON-YY') and to_date(?,'DD-MON-YY')",
            filter1.upcase, filter2.upcase) unless filter2.blank?
    end
  }

  scope :filter_like_column, ->(column, filter, upper = false) {
    if upper
      where("upper(#{column}) like ?", (upper ? filter.to_s.upcase : filter.to_s) + '%') unless filter.blank?
    else
      where("#{column} like ?", filter.to_s + '%') unless filter.blank?
    end
  }

  scope :filter_column_contains, ->(column, filter) {
    where("upper(#{column}) like ?", '%' + filter.to_s.upcase + '%') unless filter.blank?
  }

  scope :filter_column_is_in, ->(column, filter) {
    where("upper(#{column}) in #{'(' + filter.split(' ').map { |x| '\'' + x + '\'' }.join(',') + ')'}")
  }


end