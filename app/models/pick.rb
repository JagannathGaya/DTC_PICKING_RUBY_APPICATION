class Pick < ApplicationRecord

  PICK_TYPES = { bulk: I18n.t('pick.type.bulk'), pick: I18n.t('pick.type.pick'), drop: I18n.t('pick.type.drop') }
  validates :pick_type, inclusion: {in: PICK_TYPES.keys.map(&:to_s), allow_blank: false}

  belongs_to :user
  belongs_to :client
  belongs_to :wave

  scope :ordered, -> { order(:action_seq).order(:sort_key).order(:pick_type).order(:order_no) }
  scope :for_user, -> (user_id) { where('user_id = ?',user_id) }
  scope :for_client, -> (client_id) { where('client_id = ?',client_id) }
  scope :for_wave, -> (wave_id) { where('wave_id = ?',wave_id) }

  def drop?
    self.pick_type == 'drop'
  end

end

# t.integer 'user_id'
# t.integer 'client_id', null: false
# t.integer 'wave_id', null: false
# t.string 'pick_type', null: false
# t.string 'sort_key', null: false
# t.string 'path'
# t.string 'item_no', null: false
# t.string 'pick_area', null: false
# t.string 'pick_bin', null: false
# t.string 'moveto_area'
# t.string 'moveto_bin'
# t.integer 'order_no'
# t.integer 'order_suffix'
# t.integer 'line_no'
# t.integer 'lock_version', default: 0, null: false
# t.datetime 'created_at'
# t.datetime 'updated_at'
