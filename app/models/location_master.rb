class LocationMaster < TbpTable

    self.table_name = 'location_master'
    self.primary_key = 'bin_loc'

    private

end

# unit_code                                 not null varchar2(3)
# plant_code                                not null varchar2(2)
# stock_area                                not null varchar2(4)
# bin_loc                                   not null varchar2(11)
# stock_area_desc                                    varchar2(30)
# nettable                                  not null varchar2(1)
# backflush_loc                                      varchar2(1)
# staging_allowed                                    varchar2(1)
# shipping_capable                          not null varchar2(1)
# controlled                                         varchar2(1)
# cust_owned                                not null varchar2(1)
# loc_group_cd                                       varchar2(10)
# quarantine                                not null varchar2(1)
# nds_version_no                            not null number
# tenant_id                                 not null varchar2(30)
