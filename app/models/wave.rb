class Wave < ApplicationRecord

  belongs_to :user
  belongs_to :client
  has_many :picks

  scope :ordered, -> { order(:id) }
  scope :for_user, -> (user_id) { where('user_id = ?',user_id) }
  scope :for_client, -> (client_id) { where('client_id = ?',client_id) }

end

# t.integer  "user_id",                  null: false
# t.integer  "client_id",                null: false
# t.string   "order_list",               null: false
# t.integer  "lock_version", default: 0, null: false
# t.datetime "created_at"
# t.datetime "updated_at"
