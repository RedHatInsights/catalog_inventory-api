module OwnerField
  extend ActiveSupport::Concern

  included do
    validates :owner, :presence => true, :on => :create

    before_validation :set_owner, :if => proc { Insights::API::Common::Request.current.present? }, :on => :create
  end

  def set_owner
    self.owner = username
  end

  def username
    Insights::API::Common::Request.current.user.username
  rescue Insights::API::Common::IdentityError
    "system"
  end
end
