# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cnare::Application.initialize!

ActiveRecord::Base.pluralize_table_names = false
