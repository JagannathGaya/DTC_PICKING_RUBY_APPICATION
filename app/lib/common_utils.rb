module CommonUtils

  def formatted_date(value, format = :edit)
    value ? I18n.l(Date.strptime(value.to_s, '%Y-%m-%d'), format: format) : ''
  end

  def formatted_datetime(value, format = :edit)
    return nil if value.blank?
    value ? I18n.l(Date.strptime(value.to_s, '%Y-%m-%d %H:%M'), format: format) : ''
  end

  def formatted_time(value, format = :default)
    value ? l(value, format: format) : ''
  end

  def formatted_qty(value)
    return nil unless value
    css_class = 'rfloat'
    css_class << ' redlight' if value < 0
    "<span class='#{css_class}'>#{number_with_precision(value, strip_insignificant_zeros: true, delimiter: I18n.t('number.format.delimiter'))}</span>".to_s.html_safe
  end

  def formatted_value(value, precision=2)
    return nil unless value
    css_class = 'rfloat'
    css_class << ' redlight' if value < 0
    "<span class='#{css_class}'>#{number_with_precision(value, precision: precision, separator: I18n.t('number.format.separator'), delimiter: I18n.t('number.format.delimiter'))}</span>".to_s.html_safe
  end

  def formatted_order_no(tbdash_object)
    return unless tbdash_object.respond_to? 'order_no'
    return unless tbdash_object.respond_to? 'order_suffix'
    "#{tbdash_object.order_no.to_s}-#{'%02d' % tbdash_object.order_suffix}"
  end

  def btxml_wrap (name, value)
    '<NamedSubString Name="' + "#{name}" + '"' + ">\r\n" +
        "<Value>#{value}</Value>\r\n" +
        "</NamedSubString>\r\n"
  end

  def self.deny_all ( target )
    Client.all.each do |c|
      if c.permits.find_by_report_name(target).nil?
        p = Permit.new(client_id: c.id,  report_name: target, allow:false  )
        p.save!
      end
    end
  end

 def self.large_collection(rows, from=nil)
   rows > Rails.configuration.large_collection
 end

end