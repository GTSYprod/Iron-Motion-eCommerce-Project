# Configure Dart Sass build paths
# This tells dartsass-rails which SCSS files to compile and where to output them
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "active_admin.scss" => "active_admin.css"
}
