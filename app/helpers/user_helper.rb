module UserHelper

  def make_api_key_link(user)
    link_to user_make_api_key_path(user), method: :put, class: 'btn btn-sm btn-primary' do
      icon('play') + t('user.make_api_key')
    end
  end

  def edit_user_link(user)
    link_to user.email, edit_admin_user_path(user), data: {colorbox: true, colorbox_width: 800, colorbox_height: 600}
  end

  def show_user_link(user)
    return if user.admin?
    link_to admin_user_path(user), class: 'btn btn-sm btn-primary' do
      icon('list') + t('user.show')
    end
  end

  def new_user_link
    link_to new_admin_user_path, class: 'btn btn-sm btn-primary', data: {colorbox: true, colorbox_width: 800, colorbox_height: 600} do
      icon('plus') + t('user.new')
    end
  end

  def delete_user_link(user)
    return unless user
    link_to admin_user_path(user), method: :delete, data: {confirm: t('user.confirm_delete')}, class: 'btn btn-sm btn-primary' do
      icon('trash') + t('user.delete')
    end
  end

  def impersonate_link(user)
    return unless user && current_user.admin?
    link_to impersonate_admin_user_path(user), method: :put, class: 'btn btn-sm btn-primary' do
      icon('user') + t('user.impersonate')
    end
  end

  def user_unlock_link(user)
    return unless user && current_user.admin? && user.access_locked?
    link_to unlock_admin_user_path(user), method: :put, class: 'btn btn-sm btn-primary' do
      icon('user') + t('user.unlock')
    end
  end

  def user_pick_release_link(user)
    return unless user && current_user.admin?
    # return unless Wave.using('pg').exists?(user_id: user.id)
    return unless user && !user.waves.empty?
    link_to pick_release_admin_user_path(user), method: :put, class: 'btn btn-sm btn-primary' do
      icon('user') + t('user.pick_release')
    end
  end

  def list_users_link
    link_to admin_users_path, class: 'btn btn-sm btn-primary' do
      icon('list') + t('user.list')
    end
  end

  def last_seen(user)
    return I18n.t('user.never') unless user.last_sign_in_at || user.current_sign_in_at
    return time_ago_in_words(user.last_sign_in_at, include_seconds: false)+' '+I18n.t('user.ago') unless user.current_sign_in_at
    time_ago_in_words(user.current_sign_in_at, include_seconds: false)+' '+I18n.t('user.ago')
  end

  def copy_permit_link(user)
    return unless user && current_user.admin?
    link_to copy_permit_admin_user_path(user), method: :put, class: 'btn btn-sm btn-primary' do
      icon('user') + t('user.copy_permit')
    end
  end

  def user_row_color(user)
    return "table-danger" if user.admin?
    return "table-primary" if user.user?
    ""
  end

  def user_type_filter
    select_tag 'user_type_filter',
               options_for_select(User::USER_TYPES.invert.to_a.unshift([t(:all), 'A']), session[:filter]['user_type_filter'])

  end

  def user_client_filter
    select_tag 'user_client_filter',
               options_for_select(@select_clients, session[:filter]['user_client_filter'])
  end


end