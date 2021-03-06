class Homework < ActiveRecord::Base
  belongs_to :class_room
  belongs_to :homework_section
  has_one :homework_resource, :dependent => :destroy
  has_one :resource, :through => :homework_resource
end
