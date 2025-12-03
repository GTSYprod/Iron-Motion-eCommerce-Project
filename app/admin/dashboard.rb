# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # Statistics Overview
    div class: "dashboard-stats" do
      columns do
        column do
          panel "Products" do
            div class: "stat-card" do
              h2 Product.count
              para "Total Products"
              para do
                link_to "Manage Products →", admin_products_path, class: "stat-link"
              end
            end
          end
        end

        column do
          panel "Categories" do
            div class: "stat-card" do
              h2 Category.count
              para "Total Categories"
              para do
                link_to "Manage Categories →", admin_categories_path, class: "stat-link"
              end
            end
          end
        end

        column do
          panel "Orders (30 Days)" do
            div class: "stat-card" do
              h2 Order.where("created_at >= ?", 30.days.ago).count
              para "Recent Orders"
              para do
                link_to "View All Orders →", admin_orders_path, class: "stat-link"
              end
            end
          end
        end

        column do
          panel "Revenue (30 Days)" do
            div class: "stat-card" do
              h2 number_to_currency(Order.where("created_at >= ?", 30.days.ago).sum(:order_total))
              para "Total Revenue"
              para do
                link_to "Order Details →", admin_orders_path, class: "stat-link"
              end
            end
          end
        end
      end
    end

    # Order Status Breakdown
    columns do
      column do
        panel "Order Status Breakdown" do
          table_for Order.group(:order_status).count.sort_by { |k, v| -v } do
            column "Status" do |status_count|
              status_tag status_count[0]
            end
            column "Count" do |status_count|
              status_count[1]
            end
            column "Percentage" do |status_count|
              total = Order.count
              percentage = total > 0 ? (status_count[1].to_f / total * 100).round(1) : 0
              "#{percentage}%"
            end
          end
        end
      end

      column do
        panel "Quick Actions" do
          ul class: "quick-actions" do
            li link_to "Add New Product", new_admin_product_path, class: "action-link"
            li link_to "Add New Category", new_admin_category_path, class: "action-link"
            li link_to "Edit Static Pages", admin_static_pages_path, class: "action-link"
            li link_to "View Customers", admin_users_path, class: "action-link"
          end
        end
      end
    end

    # Recent Orders
    panel "Recent Orders (Last 10)" do
      if Order.any?
        table_for Order.order(created_at: :desc).limit(10) do
          column "Order #" do |order|
            link_to "##{order.id}", admin_order_path(order)
          end
          column "Customer" do |order|
            link_to order.user.full_name, admin_user_path(order.user)
          end
          column "Status" do |order|
            status_tag order.order_status
          end
          column "Items" do |order|
            order.order_items.count
          end
          column "Total" do |order|
            number_to_currency order.order_total
          end
          column "Date" do |order|
            order.created_at.strftime("%b %d, %Y")
          end
        end
      else
        para "No orders yet"
      end
    end

    # Inventory Alerts
    columns do
      column do
        panel "Low Stock Alert" do
          low_stock = Product.where(stock_status: :low_stock)
          if low_stock.any?
            table_for low_stock do
              column "Product" do |product|
                link_to product.name, admin_product_path(product)
              end
              column "Stock Quantity" do |product|
                product.stock_quantity
              end
              column "Status" do |product|
                status_tag product.stock_status, class: 'warning'
              end
            end
          else
            para "No low stock products", class: "alert-success"
          end
        end
      end

      column do
        panel "Out of Stock" do
          out_of_stock = Product.where(stock_status: :out_of_stock)
          if out_of_stock.any?
            table_for out_of_stock do
              column "Product" do |product|
                link_to product.name, admin_product_path(product)
              end
              column "Status" do |product|
                status_tag product.stock_status, class: 'error'
              end
            end
          else
            para "No out of stock products", class: "alert-success"
          end
        end
      end
    end

    # Recent Products
    panel "Recently Added Products (Last 5)" do
      if Product.any?
        table_for Product.order(created_at: :desc).limit(5) do
          column "Image" do |product|
            if product.images.attached? && product.images.first.present?
              image_tag url_for(product.images.first.variant(:thumb)), size: "50x50"
            else
              content_tag :span, "No image", style: "color: #999;"
            end
          end
          column "Name" do |product|
            link_to product.name, admin_product_path(product)
          end
          column "Category" do |product|
            product.category&.name
          end
          column "Price" do |product|
            number_to_currency product.price
          end
          column "Stock Status" do |product|
            status_tag product.stock_status
          end
          column "Added" do |product|
            product.created_at.strftime("%b %d, %Y")
          end
        end
      else
        para "No products yet"
      end
    end
  end # content
end
