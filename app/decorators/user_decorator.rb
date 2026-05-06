class UserDecorator < ApplicationDecorator
  delegate_all

  def screen_name
      model.name || model.email
  end

  def display_user_type
    User::USER_TYPES[model.user_type.to_sym] if model.user_type
  end

  def display_client
    return nil unless model.client
    return nil if model.client_id.blank? || model.client_id == 0
    model.client.cust_no+': '+model.client.cust_name
  end

  def confirm
    model.confirmed_at ? true : false
  end

  def display_api_key
    model.api_key ? I18n.t('is_yes') : I18n.t('is_no')
  end

end