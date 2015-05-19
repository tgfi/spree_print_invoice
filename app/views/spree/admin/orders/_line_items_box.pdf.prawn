move_down 235

if po_info = @order.payments.where(source_type: "Spree::PurchaseOrderDocument").first.try(:source)

  data = [
    ['Number', 'Contact Name', 'Contact Email'],
    [po_info.number, po_info.contact_name, po_info.contact_email]
  ]

  text 'Purchase Order Detail', :align => :left, :style => :bold, :size => 11

  table(data, :width => 540) do
    cells.border_width = 0.5
    row(0).font_style = :bold
  end

  move_down(25)
end


data = []

if @hide_prices
  @column_widths = { 0 => 100, 1 => 75, 1 => 165, 3 => 75 }
  @align = { 0 => :left, 1 => :right, 2 => :left, 3 => :left }
  data << [Spree.t(:sku), Spree.t(:qty), Spree.t(:item_description), Spree.t(:options)]
else
  @column_widths = { 0 => 75, 1 => 40, 2 => 215, 3 => 75, 4 => 75, 5 => 60 }
  @align = { 0 => :left, 1 => :right, 2 => :left, 3 => :left, 4 => :right, 5 => :right}
  data << [Spree.t(:sku), Spree.t(:qty), Spree.t(:item_description), Spree.t(:options), Spree.t(:price), Spree.t(:total)]
end

@order.line_items.each do |item|
  row = [ item.variant.sku, item.quantity, item.variant.product.name]
  row << item.variant.options_text
  row << item.single_display_amount.to_s unless @hide_prices
  row << item.display_total.to_s unless @hide_prices
  data << row
end

extra_row_count = 0

unless @hide_prices
  extra_row_count += 1
  data << [] * 6
  data << [nil, nil, nil, nil, Spree.t(:subtotal), @order.display_item_total.to_s]

  sales_tax = @order.all_adjustments.eligible.select { |a| a.source_type == 'Spree::TaxRate' }.map(&:amount).inject(0, :+)
  if sales_tax > 0
    data << [nil, nil, nil, nil, 'Sales Tax', "$#{sales_tax}"]
  end

  @order.all_adjustments.eligible.select { |a| a.source_type != 'Spree::TaxRate' }.each do |adjustment|
    extra_row_count += 1
    data << [nil, nil, nil, nil, adjustment.label, adjustment.display_amount.to_s]
  end

  @order.shipments.each do |shipment|
    extra_row_count += 1
    data << [nil, nil, nil, nil, shipment.shipping_method.name, shipment.display_cost.to_s]
  end

  data << [nil, nil, nil, nil, Spree.t(:total), @order.display_total.to_s]
end

text 'Line Items', :align => :left, :style => :bold, :size => 11

table(data, :width => @column_widths.values.compact.sum, :column_widths => @column_widths) do
  cells.border_width = 0.5

  row(0).borders = [:bottom]
  row(0).font_style = :bold

  last_column = data[0].length - 1
  row(0).columns(0..last_column).borders = [:top, :right, :bottom, :left]
  row(0).columns(0..last_column).border_widths = [0.5, 0, 0.5, 0.5]

  row(0).column(last_column).border_widths = [0.5, 0.5, 0.5, 0.5]

  if extra_row_count > 0
    extra_rows = row((-2-extra_row_count)..-2)
    extra_rows.columns(0..5).borders = []
    extra_rows.column(4).font_style = :bold

    row(-1).columns(0..5).borders = []
    row(-1).column(4).font_style = :bold
  end
end
