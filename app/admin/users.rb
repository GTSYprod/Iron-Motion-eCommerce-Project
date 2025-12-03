ActiveAdmin.register User do
  # Menu configuration
  menu priority: 4, label: "Customers"

  # Disable creation, editing, and deletion (read-only resource)
  actions :all, except: [:new, :create, :edit, :update, :destroy]

  # Index page configuration
  index do
    selectable_column
    id_column
    column :email
    column "Name" do |user|
      user.full_name
    end
    column "Orders" do |user|
      user.orders.count
    end
    column "Total Spent" do |user|
      number_to_currency user.orders.sum(:order_total)
    end
    column :created_at
    actions
  end

  # Filter configuration
  filter :email
  filter :first_name
  filter :last_name
  filter :created_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row "Full Name" do |user|
        user.full_name
      end
      row "Member Since" do |user|
        user.created_at.strftime("%B %d, %Y")
      end
      row "Total Orders" do |user|
        user.orders.count
      end
      row "Total Spent" do |user|
        number_to_currency user.orders.sum(:order_total)
      end
    end

    panel "Customer Addresses" do
      if user.addresses.any?
        table_for user.addresses do
          column :street_address
          column :city
          column :province
          column :postal_code
          column :country
          column "Default" do |address|
            status_tag(address.is_default ? "Yes" : "No", address.is_default ? :ok : nil)
          end
        end
      else
        para "No addresses on file"
      end
    end

    panel "Order History" do
      if user.orders.any?
        table_for user.orders.order(created_at: :desc) do
          column "Order #" do |order|
            link_to "##{order.id}", admin_order_path(order)
          end
          column :order_status do |order|
            status_tag order.order_status
          end
          column "Items" do |order|
            order.order_items.count
          end
          column :order_total do |order|
            number_to_currency order.order_total
          end
          column :created_at do |order|
            order.created_at.strftime("%b %d, %Y")
          end
        end

        div style: "margin-top: 20px;" do
          h4 "Order Summary"
          ul do
            li "Total Orders: #{user.orders.count}"
            li "Pending Orders: #{user.orders.pending.count}"
            li "Delivered Orders: #{user.orders.delivered.count}"
            li "Cancelled Orders: #{user.orders.cancelled.count}"
            li "Lifetime Value: #{number_to_currency user.orders.sum(:order_total)}"
          end
        end
      else
        para "No orders yet"
      end
    end

    panel "Shopping Cart" do
      if user.shopping_cart && user.shopping_cart.shopping_cart_items.any?
        table_for user.shopping_cart.shopping_cart_items do
          column "Product" do |item|
            if item.product
              link_to item.product.name, admin_product_path(item.product)
            else
              "Product no longer available"
            end
          end
          column :item_quantity
          column "Subtotal" do |item|
            if item.product
              number_to_currency(item.product.price * item.item_quantity)
            else
              "N/A"
            end
          end
        end

        div style: "margin-top: 10px; text-align: right;" do
          strong "Cart Total: #{number_to_currency user.shopping_cart.total}"
        end
      else
        para "Shopping cart is empty"
      end
    end
  end
end
