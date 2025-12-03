ActiveAdmin.register StaticPage do
  # Permitted parameters (Requirement 1.4)
  permit_params :title, :slug, :content, :published

  # Menu configuration
  menu priority: 5, label: "Static Pages"

  # Scopes
  scope :all, default: true
  scope :published
  scope "Drafts", :drafts

  # Index page configuration
  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :published do |page|
      status_tag(page.published ? "Published" : "Draft", class: page.published ? 'ok' : 'warning')
    end
    column :updated_at
    actions defaults: true do |page|
      link_to "Preview", preview_admin_static_page_path(page), class: "member_link"
    end
  end

  # Filter configuration
  filter :title
  filter :slug
  filter :published
  filter :created_at
  filter :updated_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :title
      row :slug
      row :published do |page|
        status_tag(page.published ? "Published" : "Draft", class: page.published ? 'ok' : 'warning')
      end
      row :content do |page|
        div class: "rich-text-content" do
          page.content.to_s.html_safe
        end
      end
      row :created_at
      row :updated_at
    end

    panel "Actions" do
      para do
        link_to "Preview This Page", preview_admin_static_page_path(static_page),
                class: "button", target: "_blank"
      end
    end
  end

  # Form configuration (Requirement 1.4: web-form editing, NOT scaffolded CRUD)
  form do |f|
    f.inputs "Page Information" do
      f.input :title, hint: "Page title (2-200 characters)"
      f.input :slug, hint: "URL-friendly identifier (auto-generated from title if left blank). Use lowercase, numbers, and hyphens only."
      f.input :published, as: :boolean,
              hint: "Publish this page to make it visible on the website"
    end

    f.inputs "Page Content" do
      f.input :content, as: :rich_text_area,
              hint: "Use the rich text editor to format your content with headings, lists, links, and more."
    end

    f.actions
  end

  # Custom member action for preview
  member_action :preview, method: :get do
    @static_page = StaticPage.find(params[:id])
    render "admin/static_pages/preview", layout: false
  end

  # Custom controller
  controller do
    def create
      # Auto-generate slug if not provided
      if params[:static_page][:slug].blank?
        params[:static_page][:slug] = params[:static_page][:title].parameterize
      end

      super
    end

    def update
      # Auto-generate slug if not provided but title changed
      if params[:static_page][:slug].blank? && params[:static_page][:title].present?
        params[:static_page][:slug] = params[:static_page][:title].parameterize
      end

      super
    end
  end
end
