ActiveAdmin.register Order do
  # Permitted parameters - STATUS ONLY (read-only resource)
  permit_params :order_status

  # Menu configuration
  menu priority: 3

  # Disable creation and deletion
  actions :all, except: [:new, :create, :destroy]

  # Scopes for filtering by status
  scope :all, default: true
  scope :pending
  scope :processing
  scope :shipped
  scope :delivered
  scope :cancelled

  # Index page configuration
  index do
    selectable_column
    id_column
    column "Customer" do |order|
      link_to order.user.full_name, admin_user_path(order.user)
    end
    column "Email" do |order|
      order.user.email
    end
    column "Items" do |order|
      order.order_items.count
    end
    column :order_total do |order|
      number_to_currency order.order_total
    end
    column :order_status do |order|
      status_tag order.order_status
    end
    column :created_at
    actions defaults: true do |order|
      if order.pending? || order.processing?
        link_to "Mark Shipped", mark_shipped_admin_order_path(order),
                method: :post, class: "member_link"
      end
      if order.shipped?
        link_to "Mark Delivered", mark_delivered_admin_order_path(order),
                method: :post, class: "member_link"
      end
    end
  end

  # Filter configuration
  filter :user, as: :select, collection: -> { User.order(:first_name) }
  filter :order_status, as: :select, collection: Order::ORDER_STATUSES
  filter :order_total
  filter :created_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row "Customer" do |order|
        link_to order.user.full_name, admin_user_path(order.user)
      end
      row "Customer Email" do |order|
        mail_to order.user.email
      end
      row :order_status do |order|
        status_tag order.order_status
      end
      row :order_total do |order|
        number_to_currency order.order_total
      end
      row :created_at
      row :updated_at
    end

    panel "Shipping Address" do
      if order.address
        attributes_table_for order.address do
          row :street_address
          row :city
          row :province
          row :postal_code
          row :country
        end
      else
        para "No shipping address specified"
      end
    end

    panel "Order Items" do
      table_for order.order_items do
        column "Product" do |item|
          if item.product
            link_to item.product.name, admin_product_path(item.product)
          else
            content_tag :span, "Product no longer available", style: "color: #999;"
          end
        end
        column "Image" do |item|
          if item.product && item.product.images.attached? && item.product.images.first.present?
            image_tag url_for(item.product.images.first.variant(:thumb)), size: "50x50"
          else
            content_tag :span, "No image", style: "color: #999;"
          end
        end
        column :quantity
        column "Price at Purchase" do |item|
          number_to_currency item.price_at_purchase
        end
        column "Subtotal" do |item|
          number_to_currency(item.quantity * item.price_at_purchase)
        end
      end

      div style: "margin-top: 20px; text-align: right;" do
        h3 do
          "Order Total: #{number_to_currency order.order_total}"
        end
      end
    end

    panel "Order History" do
      para "Order placed on #{order.created_at.strftime('%B %d, %Y at %I:%M %p')}"
      if order.updated_at != order.created_at
        para "Last updated on #{order.updated_at.strftime('%B %d, %Y at %I:%M %p')}"
      end
    end

    panel "Quick Actions" do
      div do
        if order.pending? || order.processing?
          button_to "Mark as Processing", mark_processing_admin_order_path(order),
                    method: :post, class: "button"
          button_to "Mark as Shipped", mark_shipped_admin_order_path(order),
                    method: :post, class: "button", style: "margin-left: 10px;"
          button_to "Cancel Order", cancel_order_admin_order_path(order),
                    method: :post, class: "button",
                    style: "margin-left: 10px; background-color: #d9534f;",
                    data: { confirm: "Are you sure you want to cancel this order?" }
        elsif order.shipped?
          button_to "Mark as Delivered", mark_delivered_admin_order_path(order),
                    method: :post, class: "button"
        elsif order.delivered?
          para "Order has been delivered", style: "color: #5cb85c; font-weight: bold;"
        elsif order.cancelled?
          para "Order has been cancelled", style: "color: #d9534f; font-weight: bold;"
        end
      end
    end
  end

  # Form configuration - STATUS ONLY
  form do |f|
    f.inputs "Order Status Update" do
      f.input :order_status, as: :select,
              collection: Order::ORDER_STATUSES.map { |k| [k.titleize, k] },
              hint: "Update the order status"
    end
    f.actions
  end

  # Custom member actions for quick status updates
  member_action :mark_processing, method: :post do
    order = Order.find(params[:id])
    order.update(order_status: :processing)
    redirect_to admin_order_path(order), notice: "Order marked as processing"
  end

  member_action :mark_shipped, method: :post do
    order = Order.find(params[:id])
    order.update(order_status: :shipped)
    redirect_to admin_order_path(order), notice: "Order marked as shipped"
  end

  member_action :mark_delivered, method: :post do
    order = Order.find(params[:id])
    order.update(order_status: :delivered)
    redirect_to admin_order_path(order), notice: "Order marked as delivered"
  end

  member_action :cancel_order, method: :post do
    order = Order.find(params[:id])
    if order.delivered?
      redirect_to admin_order_path(order), alert: "Cannot cancel a delivered order"
    else
      order.update(order_status: :cancelled)
      redirect_to admin_order_path(order), notice: "Order has been cancelled"
    end
  end

  # Custom controller
  controller do
    def update
      # Only allow status updates, no other changes
      if params[:order].keys.count > 1 || !params[:order].key?(:order_status)
        flash[:error] = "Only order status can be updated"
        redirect_to admin_order_path(resource)
      else
        super
      end
    end
  end

  # Batch action for status updates
  batch_action :mark_as_processing do |ids|
    Order.where(id: ids).update_all(order_status: :processing)
    redirect_to collection_path, notice: "Orders marked as processing"
  end

  batch_action :mark_as_shipped do |ids|
    Order.where(id: ids).update_all(order_status: :shipped)
    redirect_to collection_path, notice: "Orders marked as shipped"
  end
end
