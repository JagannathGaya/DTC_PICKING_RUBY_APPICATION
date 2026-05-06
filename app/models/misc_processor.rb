class MiscProcessor < TbpUvw

  self.table_name = 'tbpick_misc_proc_uvw'
  self.primary_key = 'nds_number'  # UVWS being inserted into must be based on single-table select and have primary key constraint column matching this

end

# Name                                      Null?    Type
# ----------------------------------------- -------- -------------
# NDS_NUMBER                                NOT NULL NUMBER
# ACTION                                             VARCHAR2(20)
# CARG1                                              VARCHAR2(20)
# CARG2                                              VARCHAR2(20)
# NARG1                                              NUMBER
# NARG2                                              NUMBER