class Link < ActiveRecord::Base
  attr_accessible :count_pub_target, :id, :last_year_pub_target, :source, :target, :value
end
