class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.includes(:order_items, :address).recent.page(params[:page]).per(10)
  end

  def show
    @order = current_user.orders
                        .includes(order_items: { product: { images_attachments: :blob } })
                        .includes(:address)
                        .find(params[:id])
  end
end
