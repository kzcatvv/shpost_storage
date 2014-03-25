# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all()
Unit.destroy_all()


unit1 = Unit.create(name: 'unit1_name', desc: 'unit1_desc')

superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: '11111111', name: 'superadmin', role: 'superadmin', unit: unit1)
unitadmin = User.create(email: 'unitadmin@examples.com', username: 'unitadmin', password: '11111111', name: 'unitadmin', role: 'unitadmin', unit: unit1)
user1 = User.create(email: 'gaohelie@examples.com', username: 'gaohelie', password: '11111111', name: 'gaohelie', role: 'user', unit: unit1)

