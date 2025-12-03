class PagesController < ApplicationController
  # Requirement 1.4 - Static pages
  def about
    @page = StaticPage.find_by(slug: "about-us")
  end

  def contact
    @page = StaticPage.find_by(slug: "contact-us")
  end
end
