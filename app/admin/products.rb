ActiveAdmin.register Product do
  # Permitted parameters (Requirement 1.2, 1.3)
  permit_params :name, :description, :price, :category_id, :stock_status,
                :stock_quantity, :specification, :on_sale, :is_new, images: []

  # Scopes for filtering (Requirement 2.4)
  scope :all, default: true
  scope :on_sale
  scope :new_arrivals
  scope :in_stock
  scope "Recently Updated", :recently_updated

  # Index page configuration
  index do
    selectable_column
    id_column
    column "Image" do |product|
      if product.images.attached? && product.images.first.present?
        image_tag url_for(product.images.first.variant(:thumb)), size: "50x50"
      else
        content_tag :span, "No image", style: "color: #999;"
      end
    end
    column :name
    column :category
    column :price do |product|
      number_to_currency product.price
    end
    column :stock_status do |product|
      status_tag product.stock_status
    end
    column "Stock Qty", :stock_quantity
    column :on_sale do |product|
      status_tag(product.on_sale ? "Yes" : "No", class: product.on_sale ? 'ok' : 'no')
    end
    column :is_new do |product|
      status_tag(product.is_new ? "Yes" : "No", class: product.is_new ? 'ok' : 'no')
    end
    column :updated_at
    actions
  end

  # Filter configuration
  filter :name
  filter :category
  filter :price
  filter :stock_status, as: :select, collection: Product::STOCK_STATUSES
  filter :on_sale
  filter :is_new
  filter :created_at
  filter :updated_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :category
      row :price do |product|
        number_to_currency product.price
      end
      row :stock_status do |product|
        status_tag product.stock_status
      end
      row :stock_quantity
      row :specification
      row :on_sale do |product|
        status_tag(product.on_sale ? "Yes" : "No", product.on_sale ? :ok : nil)
      end
      row :is_new do |product|
        status_tag(product.is_new ? "Yes" : "No", product.is_new ? :ok : nil)
      end
      row :created_at
      row :updated_at
    end

    panel "Product Images" do
      if product.images.attached? && product.images.any?
        div class: "product-images-grid" do
          product.images.each do |image|
            div class: "product-image-item", style: "display: inline-block; margin: 10px;" do
              image_tag url_for(image.variant(:medium)), style: "max-width: 300px; border: 1px solid #ddd; padding: 5px;"
            end
          end
        end
      else
        para "No images uploaded for this product."
      end
    end
  end

  # Form configuration (Requirements 1.2, 1.3)
  form do |f|
    f.inputs "Product Information" do
      f.input :name, hint: "Product name (3-200 characters)"
      f.input :description, as: :text, input_html: { rows: 6 },
              hint: "Detailed product description (minimum 10 characters)"
      f.input :category, as: :select,
              collection: Category.all.map { |c| [c.name, c.id] },
              include_blank: "Select a category"
    end

    f.inputs "Pricing & Flags" do
      f.input :price, min: 0.01, max: 999999.99, hint: "Product price in CAD"
      f.input :on_sale, as: :boolean, hint: "Mark this product as on sale"
      f.input :is_new, as: :boolean, hint: "Mark this product as new arrival"
    end

    f.inputs "Inventory Management" do
      f.input :stock_status, as: :select,
              collection: Product::STOCK_STATUSES.map { |k| [k.titleize.gsub('_', ' '), k] },
              hint: "Current stock availability status"
      f.input :stock_quantity, hint: "Number of units in stock"
    end

    f.inputs "Product Details" do
      f.input :specification, as: :text, input_html: { rows: 4 },
              hint: "Technical specifications (optional)"
    end

    f.inputs "Product Images" do
      if f.object.images.attached? && f.object.images.any?
        div class: "existing-images" do
          h4 "Current Images"
          f.object.images.each_with_index do |image, index|
            div style: "display: inline-block; margin: 10px; text-align: center;" do
              image_tag url_for(image.variant(:thumb)), style: "max-width: 150px; border: 1px solid #ddd; padding: 5px;"
              para "Image #{index + 1}", style: "margin: 5px 0; font-size: 12px; color: #666;"
            end
          end
        end
      end

      f.input :images, as: :file, input_html: { multiple: true },
              hint: "Upload one or more product images (JPG, PNG). Multiple images can be selected at once."
    end

    f.actions
  end

  # Custom controller for image handling
  controller do
    def update
      # Handle image attachments separately
      if params[:product][:images].present?
        @product = Product.find(params[:id])

        # Attach new images
        params[:product][:images].each do |image|
          @product.images.attach(image) unless image.blank?
        end

        # Remove images from params to avoid processing by default update
        params[:product].delete(:images)
      end

      super
    end

    def create
      # Handle image attachments for new products
      if params[:product][:images].present?
        images = params[:product].delete(:images)

        # Create product first
        @product = Product.new(permitted_params[:product])

        if @product.save
          # Attach images after product is created
          images.each do |image|
            @product.images.attach(image) unless image.blank?
          end
          redirect_to admin_product_path(@product), notice: "Product was successfully created."
        else
          render :new
        end
      else
        super
      end
    end

    def destroy
      @product = Product.find(params[:id])

      # Check if product has orders
      if @product.order_items.any?
        flash[:error] = "Cannot delete product '#{@product.name}' because it has been ordered #{@product.order_items.count} time(s). Products with orders cannot be deleted to maintain order history."
        redirect_to admin_product_path(@product)
      else
        super
      end
    end
  end

  # Batch actions
  batch_action :mark_on_sale do |ids|
    Product.where(id: ids).update_all(on_sale: true)
    redirect_to collection_path, notice: "Products marked as on sale."
  end

  batch_action :remove_sale_flag do |ids|
    Product.where(id: ids).update_all(on_sale: false)
    redirect_to collection_path, notice: "Sale flag removed from products."
  end

  batch_action :mark_as_new do |ids|
    Product.where(id: ids).update_all(is_new: true)
    redirect_to collection_path, notice: "Products marked as new arrivals."
  end

  batch_action :remove_new_flag do |ids|
    Product.where(id: ids).update_all(is_new: false)
    redirect_to collection_path, notice: "New arrival flag removed from products."
  end

  batch_action :set_in_stock do |ids|
    Product.where(id: ids).update_all(stock_status: :in_stock)
    redirect_to collection_path, notice: "Products marked as in stock."
  end

  batch_action :set_out_of_stock do |ids|
    Product.where(id: ids).update_all(stock_status: :out_of_stock)
    redirect_to collection_path, notice: "Products marked as out of stock."
  end
end
