class ShopProduct < ApplicationRecord
  validates :cost, format: { with: /A\d{1,12}(\.\d{1,2}){0,1}\z/, message: "wrong format" }
  validates :price_list, presence: true, uniqueness: { scope: [:brand, :code], message: 'is taken',
                                                       case_sensitive: false }
end
