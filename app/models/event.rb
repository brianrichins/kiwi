class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :details, type: String
  field :name, type: String
  field :user, type: String
  field :datetime, type: DateTime

  field :crop_x, type: Integer
  field :crop_y, type: Integer

  has_mongoid_attached_file :image, :styles => 
    {
      :medium => "400x300#",
      :thumb => ""
    },
    :convert_options =>
    {
      :thumb => "-gravity NorthWest -crop 80x60+200+200 +repage"
    }
end
