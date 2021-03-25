class Public::OrdersController < ApplicationController
  def index
    @orders = Order.all
    
  end

  def show
    @order = Order.find(params[:id])
    @orders = Order.all
  end

  def new
    @order = Order.new
    @addresses = current_customer.addresses
  end

  def create
    @order = Order.new(order_params)
    @order.customer_id = current_customer.id
    if @order.save

      @cart_products = current_customer.cart_products.all
        @cart_products.each do |cart_product|
          @order_products = @order.order_products.new
          @order_products.product_id = cart_product.product.id
          @order_products.quantity = cart_product.quantity
          @order_products.tax_in_price = cart_product.product.tax_included_price.to_i
          @order_products.save
          current_customer.cart_products.destroy_all
        end

      redirect_to orders_thanks_path
    else
      render :confirm
    end
  end

  def confirm
    @order = Order.new(order_params)
    @cart_product = current_customer.cart_products

    @order.postage = 800
    @order.total_price = 0
    @cart_product.each do |cp|
      @order.total_price += cp.quantity * cp.product.tax_included_price.to_i
    end
    @billing_amount =  @order.postage + @order.total_price

    if params[:order][:address_option] == "0"
      @order.shipping_postal_code = current_customer.postal_code
      @order.shipping_address = current_customer.address
      @order.shipping_name = current_customer.last_name + current_customer.first_name
    elsif params[:order][:address_option] == "1"
      @address = Address.find(params[:order][:order_address])
      @order.shipping_postal_code = @address.postal_code
      @order.shipping_address = @address.address
      @order.shipping_name = @address.address_name
    end

  end

  def thanks
  end

  private

  def order_params
    params.require(:order).permit(:shipping_postal_code, :shipping_address, :shipping_name, :payment_method, :total_price, :postage)
  end

  def products_name_params
    params.require(:product).permit(:genre, :name, :introduction, :price, :image, :sales_status)
  end

  def order_product_params
    params.require(:order_product).permit(:order, :product, :quantity, :product_status, :tax_in_price)
  end
end
