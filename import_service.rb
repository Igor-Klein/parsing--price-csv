class Migrations::ImportService
  require 'activerecord-import/base'
  require 'activerecord-import/active_record/adapters/postgresql_adapter'

  def initialize(file_path = nil, price_list_name = nil)
    file_path ||= 'spec/fixtures/files/shop/price_1.csv'
    @array = CSV.foreach(file_path, headers: true, col_sep: ';')
    @price_list = price_list_name || file_path.split('/').last
    @products = []
    @errors = []
  end

  def create
    if @array.none?
      message = 'empty file'
      return Rails.logger.info(message)
    end

    first_row = @array.first
    code_name = get_code_name(first_row)
    stock_name = get_stock_name(first_row)

    @array.each do |entry|
      brand = entry['Производитель'].try(:downcase)
      code = entry[code_name].try(:downcase)
      stock = entry[stock_name]
      cost = entry['Цена']
      name = entry['Наименование']

      if brand.blank?
        message = "brand is empty, row: #{entry}"
        @errors << message
        next
      end

      if code.blank?
        message = "code is empty, row: #{entry}"
        @errors << message
        next
      end

      if stock.blank?
        message = "stock is empty, row: #{entry}"
        @errors << message
        next
      end

      if cost.blank?
        message = "cost is empty, row: #{entry}"
        @errors << message
        next
      end

      unless cost.match?(/^\d{1,12}(\.\d{1,2}){0,1}$/)
        message = "wrong cost format, row: #{entry}"
        @errors << message
        next
      end

      params = {
        price_list: @price_list,
        brand: brand,
        code: code,
        stock: stock,
        cost: cost,
        name: name,
      }

      product = ShopProduct.new(params)
      @products << product
    end

    result = ShopProduct.import(@products, validate: false, on_duplicate_key_update: { conflict_target:
                        [:price_list, :brand, :code], columns: [:stock, :cost, :name, :updated_at] })
    ids = result[:ids]
    ShopProduct.where.not(id: ids).destroy_all
    puts('result:', result)
    { errors: @errors }
  end

  private

  def get_code_name(row)
    code_names = ['Артикул', 'Номер']
    code_names.each do |name|
      return name unless row[name].nil?
    end
  end

  def get_stock_name(row)
    stock_names = ['Кол-во', 'Количество']
    stock_names.each do |name|
      return name unless row[name].nil?
    end
  end
end
