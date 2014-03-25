# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all()

superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: '11111111', name: 'superadmin', role: 'superadmin')
unitadmin = User.create(email: 'unitadmin@examples.com', username: 'unitadmin', password: '11111111', name: 'unitadmin', role: 'unitadmin')
user1 = User.create(email: 'gaohelie@examples.com', username: 'gaohelie', password: '11111111', name: 'gaohelie', role: 'user')
Unit.create(name: '闸北')
User.create(email: '111@examples.com', username: 'unit', password: '111', name: 'asd', role: 'unitadmin', unit_id: 1)
