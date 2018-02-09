@hide_prices = params[:template] == "packaging_slip"

render :partial => "spree/admin/orders/print"
