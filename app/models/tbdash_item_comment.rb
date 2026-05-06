class TbdashItemComment < TbpView

  EXCLUDE_COLUMNS = %w[item_slug]

  self.table_name = 'tbdash_item_comments_vw'
  self.primary_key = 'item_no'

  scope :ordered, -> { order(:comment_seq).order(:comment_text) }

  scope :for_type, -> (filter) { where('comment_type = ?',filter.upcase).ordered unless filter.blank? }
end
