class Provider
  include Mongoid::Document
  embedded_in :user

  field :provider, type: String
  field :uid, type: Integer

  field :token, type: String
  field :secret, type: String

  field :name, type: String

  field :image, type: String
  field :birthday, :type => Date
  field :gender, type: String
end
