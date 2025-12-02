ActiveAdmin.register Category do
  # Permitted parameters
  permit_params :name, :description, :parent_category_id

  # Index page configuration
  index do
    selectable_column
    id_column
    column :name
    column "Parent Category" do |category|
      category.parent_category&.name || "None (Top-Level)"
    end
    column "Products" do |category|
      category.products.count
    end
    column "Subcategories" do |category|
      category.subcategories.count
    end
    column :created_at
    actions
  end

  # Filter configuration
  filter :name
  filter :parent_category, as: :select, collection: -> { Category.where(parent_category_id: nil) }
  filter :created_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row "Parent Category" do |category|
        if category.parent_category
          link_to category.parent_category.name, admin_category_path(category.parent_category)
        else
          "None (Top-Level)"
        end
      end
      row "Subcategories" do |category|
        if category.subcategories.any?
          ul do
            category.subcategories.each do |sub|
              li link_to(sub.name, admin_category_path(sub))
            end
          end
        else
          "No subcategories"
        end
      end
      row "Products" do |category|
        category.products.count
      end
      row :created_at
      row :updated_at
    end

    panel "Products in this Category" do
      if category.products.any?
        table_for category.products do
          column :name do |product|
            link_to product.name, admin_product_path(product)
          end
          column :price do |product|
            number_to_currency product.price
          end
          column :stock_status
        end
      else
        para "No products in this category yet."
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs "Category Details" do
      f.input :name, hint: "Unique category name"
      f.input :description, as: :text, input_html: { rows: 4 },
              hint: "Optional description of this category"
      f.input :parent_category,
              as: :select,
              collection: Category.where.not(id: f.object.id).map { |c| [c.name, c.id] },
              include_blank: "None (Top-Level Category)",
              hint: "Select a parent category to create a subcategory"
    end
    f.actions
  end

  # Custom controller for deletion protection
  controller do
    def destroy
      @category = Category.find(params[:id])

      if @category.products.any?
        flash[:error] = "Cannot delete category '#{@category.name}' because it has #{@category.products.count} product(s). Please reassign or delete the products first."
        redirect_to admin_category_path(@category)
      elsif @category.subcategories.any?
        flash[:error] = "Cannot delete category '#{@category.name}' because it has #{@category.subcategories.count} subcategory(ies). Please reassign or delete the subcategories first."
        redirect_to admin_category_path(@category)
      else
        super
      end
    end
  end
end
