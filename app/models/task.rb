class Task < ApplicationRecord
  include OwnerField

  belongs_to :tenant
  belongs_to :source

  validates :state,  :inclusion => {:in => %w[pending queued running timedout completed]}
  validates :status, :inclusion => {:in => %w[ok warn unchanged error]}

  acts_as_tenant(:tenant)

  def service_options
    {:tenant_id => tenant.id, :source_id => source.id, :task => self}
  end

  def dispatch
  end

  def timed_out?
    time_interval = ClowderConfig.instance["SOURCE_REFRESH_TIMEOUT"] * 60 # in seconds
    state != 'completed' && created_at + time_interval < Time.current
  end
end
