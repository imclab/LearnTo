class ClassRoom < ActiveRecord::Base  
  validates :name,  :presence => true
  validates :occupancy, :presence => true
  validates :price, :presence => true
  validates_numericality_of :price
  validates_numericality_of :occupancy
  
  has_many :user_permissions
  has_many :users, :through => :user_permissions
  
  has_many :resource_pages, :dependent => :destroy
  has_many :sections, :through => :resource_pages
  has_many :resources
  
  has_many :announcements, :dependent => :destroy
  has_one :forum, :dependent => :destroy

  belongs_to :resource, :foreign_key => "description_id"

  belongs_to :user
end

