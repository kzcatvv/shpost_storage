class Sequence < ActiveRecord::Base
  belongs_to :unit

  Barcodes = {Shelf: 'SH', Specification: 'SP', Purchase: 'PUR', ManualStock: 'MS', Business: 'BUS', Supplier: 'SUP', OrderReturn: 'OR', Keyclientorder: 'KCO', Order: 'ORD', Task: 'TAS', Relationship: 'REL', MoveStock: 'MOS'}


  Batchs = {PurchaseArrival: 'PA', PurchaseDetail: 'PD', Keyclientorder: 'KCO', Order: 'ORD', OrderReturn: 'OR'}


  Barcodes.each_key do |x|
    x.to_s.constantize.class_eval do
      self.before_save do |obj|
        if obj.respond_to? :no
          if obj.no.blank?
            obj.no = Sequence.generate_sequence(obj.unit, obj.class)
            obj.barcode = Sequence.generate_barcode(obj.unit, obj.class, obj.no)
          end
        end
        if obj.barcode.blank?
          obj.barcode = Sequence.generate_barcode(obj.unit, obj.class, Sequence.generate_sequence(obj.unit, obj.class))
        end
        if obj.respond_to? :sku
          obj.sku = obj.barcode
        end
        return true
      end
    end
  end

  Batchs.each_key do |x|
    x.to_s.constantize.class_eval do
      self.before_save do |obj|
        if obj.batch_no.blank?
          obj.batch_no = Sequence.generate_batch(obj.unit, obj.class, ((obj.respond_to? :no) ? obj.no : Sequence.generate_sequence(obj.unit, obj.class)))
        end
        return true
      end
    end
  end

  def self.generate_sequence(unit, _class)
    get_count(unit, _class).to_s(16).upcase.rjust(10, '0')
  end

  def self.generate_barcode(unit, _class, count)
    self.generate_begin(unit, _class) + count + generate_verify(count)
  end

   def self.generate_batch(unit, _class, count)
    Time.now.strftime('%Y%m%d') + count
  end

  def self.generate_verify(count)
    count_str = count.to_s
    sum = (1..count_str.size).inject {|sum, n| sum += ((n.odd?) ? count_str[n-1].to_i : count_str[n-1].to_i*3)}
    ((10 - sum % 10) % 10).to_s
  end

  def self.get_count(unit, _class)
    sequence = where(unit: unit, entity: _class.to_s).first
    if sequence.blank?
      sequence = Sequence.create(unit: unit, entity: _class.to_s, count: 1)
    end
    sequence.update(count: sequence.count + 1)
    sequence.count - 1
  end

  def self.generate_begin(unit, _class)
    Barcodes[_class.name.to_sym] + ((unit.short_name.blank?) ? "": unit.short_name)
  end

  def generate_sequecne(_class)
    _class.class_eval do
      before_save do |obj|
        obj.barcode = Sequence.generate_sequece(obj.unit, _class)
      end
    end
  end
end