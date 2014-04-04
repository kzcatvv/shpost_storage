require 'spec_helper'

describe Stock do
  it "is valid with specification_id actual_amount virtual_amount" do
    expect(FactoryGirl.build(:stock)).to be_valid
  end

  it "is invalid without a actual_amount" do
    expect(FactoryGirl.build(:invalid_without_aa_stock)).to have(1).errors_on(:actual_amount)
  end

  it "is invalid without a virtual_amount" do
    expect(FactoryGirl.build(:invalid_without_va_stock)).to have(1).errors_on(:virtual_amount)
  end

  it "is invalid without a specification_id" do
    expect(FactoryGirl.build(:invalid_without_specification_stock)).to have(1).errors_on(:specification_id)
  end

  it "get available stock with same specification, business, supplier, batch_no" do
    specification = Specification.find 1
    business = Business.find 1
    supplier = Supplier.find 1
    batch_no = '00002'
    # amount = 100
    stock = Stock.get_available_stock(specification, business, supplier, batch_no)
    # stocks.each do |stock|
    expect(stock).to be_a(Stock)
    expect(stock).to be_persisted
    expect(stock.specification).to eq(specification)
    expect(stock.business).to eq(business)
    expect(stock.supplier).to eq(supplier)
    expect(stock.shelf.shelf_code).to eq("A2-01-01-01-02")
    expect(stock.is_available?)#.to be true
  end

  it "get available stock with same specification, business, supplier" do
    specification = Specification.find 1
    business = Business.find 1
    supplier = Supplier.find 1
    batch_no = '00003'
    # amount = 100
    stock = Stock.get_available_stock(specification, business, supplier, batch_no)
    # stocks.each do |stock|
    expect(stock).to be_a(Stock)
    expect(stock).to be_persisted
    expect(stock.specification).to eq(specification)
    expect(stock.business).to eq(business)
    expect(stock.supplier).to eq(supplier)
    expect(stock.shelf.shelf_code).to eq("A2-01-01-01-01")
    expect(stock.is_available?)#.to be true
  end

  it "get available stock with different specification or business or supplier" do
    specification = Specification.find 2
    business = Business.find 1
    supplier = Supplier.find 1
    batch_no = '00003'
    # amount = 100
    stock = Stock.get_available_stock(specification, business, supplier, batch_no)
    # stocks.each do |stock|
    expect(stock).to be_a(Stock)
    expect(stock).to be_persisted
    expect(stock.specification).to eq(specification)
    expect(stock.business).to eq(business)
    expect(stock.supplier).to eq(supplier)
    expect(stock.shelf.shelf_code).to eq("A2-01-01-02-01")
    expect(stock.is_available?)#.to be true
  end

  # it "is_available" do
  #   FactoryGirl.build(:stock)
  #   expect
  # end
end
