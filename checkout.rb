class Checkout

  def initialize(promotional_rules)
    @cart              = []
    @subtotal          = 0
    @promotional_rules = promotional_rules
  end

  def scan_basket(basket)
    basket.each do |item|
      scan(item)
    end
  end

  def scan(item)
    @cart << item
    @subtotal += item[:price]
  end

  def total
    @promotional_rules.sort_by{|rule| rule[:order]}.each do |rule|
      if rule[:threshold] && rule[:percentage] && rule[:threshold] <= @subtotal
        @subtotal -= ((@subtotal.to_f / 100.0) * rule[:percentage].to_f)
      elsif rule[:new_price] && rule[:item] && rule[:gte]
        @subtotal -= @cart.group_by{
          |item| item
        }.keep_if{
          |_, e| e.length > 1
        }.map{
          |k, v| (k[:price].to_f - rule[:new_price].to_f) * v.size.to_f
        }.reduce(0, :+)
      end
    end

    return (@subtotal / 100).round(2)
  end

end

products = [
  {code: '001', name: 'Lavender Heart', price: 925},
  {code: '002', name: 'Personalised cufflinks', price: 4500},
  {code: '003', name: 'Kids T-Shirt', price: 1995}
]

baskets = [
  [products[0], products[1], products[2]],
  [products[0], products[2], products[0]],
  [products[0], products[1], products[0], products[2]]
]

rules = [
  {order: 1, new_price: 850, item: '001', gte: 2},
  {order: 2, percentage: 10, threshold: 6000}
]

baskets.each_with_index do |basket, index|
  co = Checkout.new(rules)
  co.scan_basket(basket)
  price = co.total

  puts "basket:  #{index + 1}"
  puts "price:   #{price}"
  puts "--------------"
end
