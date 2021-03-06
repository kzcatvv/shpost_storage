# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# User.destroy_all()
# Unit.destroy_all()
# Storage.destroy_all()
# Role.destroy_all()
# Area.destroy_all()
# Supplier.destroy_all()
# Business.destroy_all()
# Goodstype.destroy_all()
# Commodity.destroy_all()
# Specification.destroy_all()
# Shelf.destroy_all()
# Stock.destroy_all()
# StockLog.destroy_all()

# unit1 = Unit.create(name: '闸北区局', desc: '闸北区局', no: StorageConfig.config["unit"]['zb_id'])
# # unit1 = Unit.create(name: 'unit1_name', desc: 'unit1_desc', no: '0001')
# unit2 = Unit.create(name: 'unit2_name', desc: 'unit2_desc', no: '0002')

# storage11 = Storage.create(name: '闸北仓库', desc: '闸北仓库', unit: unit1)
# storage12 = Storage.create(name: 's12', desc: 's12_desc', unit: unit1)
# storage21 = Storage.create(name: 's21', desc: 's21_desc', unit: unit2)

# superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: '11111111', name: 'superadmin', role: 'superadmin', unit_id: 0)
# unit1admin = User.create(email: 'unit1admin@examples.com', username: 'unit1admin', password: '11111111', name: 'unit1admin', role: 'unitadmin', unit: unit1)
# user11 = User.create(email: 'gaohelie@examples.com', username: 'gaohelie', password: '11111111', name: 'gaohelie', role: 'user', unit: unit1)

# unit2admin = User.create(email: 'unit2admin@examples.com', username: 'unit2admin', password: '11111111', name: 'unit2admin', role: 'unitadmin', unit: unit2)
# user21 = User.create(email: 'user21@example.com', username: 'user21', password: '11111111', name: 'user21', role: 'user', unit: unit2)
# user22 = User.create(email: 'user22@example.com', username: 'user22', password: '11111111', name: 'user22', role: 'user', unit: unit2)

# role_u11_s11_1 = Role.create(user: user11, storage: storage11, role: 'admin')
# role_u11_s11_2 = Role.create(user: user11, storage: storage11, role: 'purchase')
# role_u11_s11_3 = Role.create(user: unit1admin, storage: storage11, role: 'admin')
# role_u11_s11_4 = Role.create(user: unit1admin, storage: storage11, role: 'purchase')
# role_u11_s12_1 = Role.create(user: user11, storage: storage12, role: 'purchase')
# role_u11_s12_2 = Role.create(user: user11, storage: storage12, role: 'sorter')
# role_u11_s12_3 = Role.create(user: unit1admin, storage: storage12, role: 'purchase')
# role_u11_s12_4 = Role.create(user: unit1admin, storage: storage12, role: 'sorter')
# role_u22_s21_1 = Role.create(user: user22, storage: storage21, role: 'admin')

# area111 = Area.create(storage: storage11, name: '退货区', desc: '退货区_desc', area_code: 'A1')
# area112 = Area.create(storage: storage11, name: '发货区', desc: '发货区_desc', area_code: 'A2')
# area121 = Area.create(storage: storage12, name: '退货区', desc: '退货区_desc', area_code: 'B1')

# shelf1111 = Shelf.create(area: area111, shelf_code: 'A1-01-01-01-01-01', area_length: 1, area_width: 1, area_height: 1, shelf_row: 1, shelf_column: 1, max_weight: 100, max_volume: 200)
# shelf1112 = Shelf.create(area: area111, shelf_code: 'A1-01-01-01-01-02', area_length: 1, area_width: 1, area_height: 1, shelf_row: 1, shelf_column: 2, max_weight: 100, max_volume: 200)

# supplier1 = Supplier.create(no: 'G001',name: '供应商1',address: '供应商地址1',phone: '12345123451',unit: unit1)
# supplier2 = Supplier.create(no: 'G002',name: '供应商2',address: '供应商地址2',phone: '12345123452',unit: unit1)

# business1 = Business.create(name: '号码百事通',email: 'business1@test.com',contactor: '号码百事通联系人',phone: '22334455667',address: '号码百事通地址',desc: '号码百事通备注',unit: unit1, no: StorageConfig.config["business"]['bst_id'], secret_key: '12345')
# business2 = Business.create(name: '交通银行',email: 'business2@test.com',contactor: '交通银行联系人',phone: '22334455668',address: '交通银行地址',desc: '交通银行备注',unit: unit1, no: StorageConfig.config["business"]['jh_id'], secret_key: '12345')
# business3 = Business.create(name: '平安万里通',email: 'business3@test.com',contactor: '平安联系人',phone: '22334455669',address: '平安地址',desc: '平安备注',unit: unit1, no: StorageConfig.config["business"]['pajf_id'], secret_key: '12345')

# # Thirdpartcode.create business_id: 1, specification_id: 1, external_code: '000000002', supplier_id: 1


# goodstype1 = Goodstype.create(gtno: 'SL01',name: '商品类型1', unit: unit1)
# goodstype2 = Goodstype.create(gtno: 'SL02',name: '商品类型2', unit: unit1)

# commodity1 = Commodity.create(no: 'S001',name: '商品1',goodstype: goodstype1, unit: unit1)
# commodity2 = Commodity.create(no: 'S002',name: '商品2',goodstype: goodstype1, unit: unit1)

# specification1 = Specification.create(commodity: commodity1, name: 'Sname1', sku: '1')
# specification2 = Specification.create(commodity: commodity1, name: 'Sname2', sku: '2')

# shelf1 = Shelf.create(shelf_code: "A2-01-01-01-01", area: area112, priority_level: 1)
# shelf2 = Shelf.create(shelf_code: "A2-01-01-01-02", area: area112, priority_level: 2)
# shelf3 = Shelf.create(shelf_code: "A2-01-01-02-01", area: area112, priority_level: 3)
# shelf4 = Shelf.create(shelf_code: "A2-01-01-02-02", area: area112, priority_level: 4)

# stock_0_1 = Stock.create(shelf: shelf1, specification: specification1, supplier: supplier1, business: business1, actual_amount: 5, virtual_amount: 5, batch_no: '00001')
# stock_0_2 = Stock.create(shelf: shelf2, specification: specification1, supplier: supplier1, business: business1, actual_amount: 5, virtual_amount: 5, batch_no: '00002')
# #stock3 = Stock.create(shelf: shelf2, specification: specification2, supplier: supplier2, business: business2, batch_no: '00003')
# #stock3 = Stock.create(shelf: shelf2, specification: specification2, supplier: supplier2, business: business2, batch_no: '00004')


# stock1 = Stock.create(shelf: shelf1111, business: business1, supplier: supplier1, batch_no: '1', specification: specification1, actual_amount: 5, virtual_amount: 5, desc: 'desc')
# stock2 = Stock.create(shelf: shelf1111, business: business1, supplier: supplier2, batch_no: '2', specification: specification2, actual_amount: 7, virtual_amount: 8, desc: 'desc')
# stock3 = Stock.create(shelf: shelf1112, business: business2, supplier: supplier1, batch_no: '3', specification: specification1, actual_amount: 13, virtual_amount: 17, desc: 'desc')
# stock4 = Stock.create(shelf: shelf1111, business: business2, supplier: supplier2, batch_no: '4', specification: specification1, actual_amount: 2, virtual_amount: 3, desc: 'desc')
# stock5 = Stock.create(shelf: shelf1112, business: business1, supplier: supplier1, batch_no: '5', specification: specification2, actual_amount: 0, virtual_amount: 0, desc: 'desc')

# stock_log1 = StockLog.create(user: user11, stock: stock1, operation: 'create_stock', status: 'waiting', amount: 3, operation_type: 'in', desc: 'desc')
# stock_log2 = StockLog.create(user: user11, stock: stock2, operation: 'create_stock', status: 'waiting', amount: 15, operation_type: 'in', desc: 'desc')
# stock_log3 = StockLog.create(user: user11, stock: stock3, operation: 'create_stock', status: 'checked', amount: 8, operation_type: 'in', desc: 'desc')
# stock_log4 = StockLog.create(user: unit1admin, stock: stock4, operation: 'create_stock', status: 'waiting', amount: 10, operation_type: 'in', desc: 'desc')
# stock_log5 = StockLog.create(user: unit1admin, stock: stock5, operation: 'create_stock', status: 'waiting', amount: 46, operation_type: 'in', desc: 'desc')

# logistic1 = Logistic.create(name: "国际小包平",print_format: "gjxbp", is_getnum: true, is_default: false, wl_no: "WL0001" )
# logistic2 = Logistic.create(name: "国际小包挂",print_format: "gjxbg", is_getnum: true, is_default: false, wl_no: "WL0002" )
# logistic3 = Logistic.create(name: "国内小包",print_format: "gnxb", is_getnum: true, is_default: false, wl_no: "WL0003" )
# logistic4 = Logistic.create(name: "天天快递",print_format: "ttkd", is_getnum: true, is_default: false, wl_no: "WL0004" )
logistic5 = Logistic.create(name: "EMS",print_format: "ems", is_getnum: true, is_default: false, wl_no: "WL0005" )
logistic6 = Logistic.create(name: "百世汇通",print_format: "bsht", is_getnum: true, is_default: false, wl_no: "WL0006" )
logistic7 = Logistic.create(name: "同城小包",print_format: "tcsd", is_getnum: true, is_default: false, wl_no: "WL0007" )
logistic8 = Logistic.create(name: "其他",print_format: "qt", is_getnum: true, is_default: false, wl_no: "WL0008" )
# country_code1 = CountryCode.create(chinese_name: "澳大利亚",english_name: "AUSTRALIA",code: "AU",surfmail_partition_no: "8", regimail_partition_no: "3", is_mail: true)
# country_code2 = CountryCode.create(chinese_name: "巴西",english_name: "BRAZIL",code: "BR",surfmail_partition_no: "5", regimail_partition_no: "7", is_mail: true)
# country_code3 = CountryCode.create(chinese_name: "朝鲜",english_name: "KOREA",code: "KP",surfmail_partition_no: "4", regimail_partition_no: "5", is_mail: true)
# country_code4 = CountryCode.create(chinese_name: "德国",english_name: "GERMANY",code: "DE",surfmail_partition_no: "8", regimail_partition_no: "3", is_mail: true)
# country_code5 = CountryCode.create(chinese_name: "俄罗斯",english_name: "RUSSIA",code: "RU",surfmail_partition_no: "7", regimail_partition_no: "11", is_mail: true)
# country_code6 = CountryCode.create(chinese_name: "法国",english_name: "FRANCE",code: "FR",surfmail_partition_no: "4", regimail_partition_no: "5", is_mail: true)
# country_code7 = CountryCode.create(chinese_name: "古巴",english_name: "CUBA",code: "CU",surfmail_partition_no: "5", regimail_partition_no: "10", is_mail: true)
# country_code8 = CountryCode.create(chinese_name: "韩国",english_name: "SOUTH KOREA",code: "KR",surfmail_partition_no: "2", regimail_partition_no: "2", is_mail: true)
# country_code9 = CountryCode.create(chinese_name: "加拿大",english_name: "CANADA",code: "CA",surfmail_partition_no: "4", regimail_partition_no: "5", is_mail: true)
# country_code10 = CountryCode.create(chinese_name: "马来西亚",english_name: "MALAYSIA",code: "MY",surfmail_partition_no: "2", regimail_partition_no: "2", is_mail: true)
# country_code11 = CountryCode.create(chinese_name: "美国",english_name: "AMERICA",code: "US",surfmail_partition_no: "4", regimail_partition_no: "5", is_mail: true)
# country_code12 = CountryCode.create(chinese_name: "日本",english_name: "JAPAN",code: "JP",surfmail_partition_no: "1", regimail_partition_no: "1", is_mail: true)
# country_code13 = CountryCode.create(chinese_name: "瑞士",english_name: "SWITZERLAND",code: "CH",surfmail_partition_no: "3", regimail_partition_no: "3", is_mail: true)
# country_code14 = CountryCode.create(chinese_name: "泰国",english_name: "THAILAND",code: "TH",surfmail_partition_no: "2", regimail_partition_no: "2", is_mail: true)
# country_code15 = CountryCode.create(chinese_name: "新加坡",english_name: "SINGAPORE",code: "SG",surfmail_partition_no: "2", regimail_partition_no: "2", is_mail: true)
# country_code16 = CountryCode.create(chinese_name: "意大利",english_name: "ITALY",code: "IT",surfmail_partition_no: "3", regimail_partition_no: "3", is_mail: true)
# country_code17 = CountryCode.create(chinese_name: "英国",english_name: "BRITAIN",code: "GB",surfmail_partition_no: "8", regimail_partition_no: "5", is_mail: true)
# country_code18 = CountryCode.create(chinese_name: "中国台湾",english_name: "CHINESE TAIWAN",code: "TW",surfmail_partition_no: "0", regimail_partition_no: "0", is_mail: true)
# country_code19 = CountryCode.create(chinese_name: "中国香港",english_name: "CHINESE HONGKONG",code: "HK",surfmail_partition_no: "0", regimail_partition_no: "0", is_mail: true)
# country_code20 = CountryCode.create(chinese_name: "中国澳门",english_name: "CHINESE MACAO",code: "MO",surfmail_partition_no: "0", regimail_partition_no: "0", is_mail: true)