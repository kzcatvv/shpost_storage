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
role_u11_s12_1 = Role.create(user: user11, storage: storage12, role: 'purchase')
role_u11_s12_2 = Role.create(user: user11, storage: storage12, role: 'sorter')
role_u22_s21_1 = Role.create(user: user22, storage: storage21, role: 'admin')
