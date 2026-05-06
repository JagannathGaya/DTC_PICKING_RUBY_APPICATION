class ItemTransType < TbpLov

    self.table_name = 'tbdash_item_trans_types_vw'
    self.primary_key = 'trans_type'

    private

end

# trans_type                                not null varchar2(1)
# description                                        varchar2(50)
# lov_id                                    not null varchar2(1)
# lov_label                                          varchar2(52)
