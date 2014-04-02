# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all()
Unit.destroy_all()
Storage.destroy_all()
Role.destroy_all()
Area.destroy_all()


unit1 = Unit.create(name: 'unit1_name', desc: 'unit1_desc')
unit2 = Unit.create(name: 'unit2_name', desc: 'unit2_desc')

storage11 = Storage.create(name: 's11', desc: 's11_desc', unit: unit1)
storage12 = Storage.create(name: 's12', desc: 's12_desc', unit: unit1)
storage21 = Storage.create(name: 's21', desc: 's21_desc', unit: unit2)

superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: '11111111', name: 'superadmin', role: 'superadmin', unit_id: 0)
unit1admin = User.create(email: 'unit1admin@examples.com', username: 'unit1admin', password: '11111111', name: 'unit1admin', role: 'unitadmin', unit: unit1)
user11 = User.create(email: 'gaohelie@examples.com', username: 'gaohelie', password: '11111111', name: 'gaohelie', role: 'user', unit: unit1)

unit2admin = User.create(email: 'unit2admin@examples.com', username: 'unit2admin', password: '11111111', name: 'unit2admin', role: 'unitadmin', unit: unit2)
user21 = User.create(email: 'user21@example.com', username: 'user21', password: '11111111', name: 'user21', role: 'user', unit: unit2)
user22 = User.create(email: 'user22@example.com', username: 'user22', password: '11111111', name: 'user22', role: 'user', unit: unit2)

role_u11_s11_1 = Role.create(user: user11, storage: storage11, role: 'admin')
role_u11_s11_2 = Role.create(user: user11, storage: storage11, role: 'purchase')
role_u11_s11_3 = Role.create(user: unit1admin, storage: storage11, role: 'admin')
role_u11_s11_4 = Role.create(user: unit1admin, storage: storage11, role: 'purchase')
role_u11_s12_1 = Role.create(user: user11, storage: storage12, role: 'purchase')
role_u11_s12_2 = Role.create(user: user11, storage: storage12, role: 'sorter')
role_u11_s12_3 = Role.create(user: unit1admin, storage: storage12, role: 'purchase')
role_u11_s12_4 = Role.create(user: unit1admin, storage: storage12, role: 'sorter')
role_u22_s21_1 = Role.create(user: user22, storage: storage21, role: 'admin')

area111 = Area.create(storage: storage11, name: '退货区', desc: '退货区_desc', area_code: 'A1')
area112 = Area.create(storage: storage11, name: '发货区', desc: '发货区_desc', area_code: 'A2')
area121 = Area.create(storage: storage12, name: '退货区', desc: '退货区_desc', area_code: 'B1')

supplier1 = Supplier.create(sno: 'G001',name: '供应商1',address: '供应商地址1',phone: '12345123451',unit: unit1)
supplier2 = Supplier.create(sno: 'G002',name: '供应商2',address: '供应商地址2',phone: '12345123452',unit: unit1)

business1 = Business.create(name: '商户1',email: 'business1@test.com',contactor: '商户1联系人',phone: '22334455667',address: '商户1地址',desc: '商户1备注',unit: unit1)
business2 = Business.create(name: '商户2',email: 'business2@test.com',contactor: '商户2联系人',phone: '22334455668',address: '商户2地址',desc: '商户2备注',unit: unit1)

goodstype1 = Goodstype.create(gtno: 'SL01',name: '商品类型1', unit: unit1)
goodstype2 = Goodstype.create(gtno: 'SL02',name: '商品类型2', unit: unit1)

commodity1 = Commodity.create(cno: 'S001',name: '商品1',goodstype: goodstype1, unit: unit1)
commodity2 = Commodity.create(cno: 'S002',name: '商品2',goodstype: goodstype1, unit: unit1)

specification1 = Specification.create(commodity: commodity1, model: 'model1',size: 'small',color: 'red')
specification2 = Specification.create(commodity: commodity1, model: 'model2',size: 'big',color: 'green')
