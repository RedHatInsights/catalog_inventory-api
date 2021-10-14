class Task < ApplicationRecord
  include OwnerField

  belongs_to :tenant
  belongs_to :source

  validates :state,  :inclusion => {:in => %w[pending queued running timedout completed]}
  validates :status, :inclusion => {:in => %w[ok warn unchanged error]}

  acts_as_tenant(:tenant)

  before_update :prevent_update, :if => proc { state_changed?(:from => 'timedout', :to => 'completed') }

  @timeout_interval = 30 * 60 # 30 mins

  def self.timeout_interval
    @timeout_interval
  end

  def timed_out?
    ['pending', 'queued', 'running'].include?(state) && created_at + self.class.timeout_interval < Time.current
  end

  def service_options
    {:tenant_id => tenant.id, :source_id => source.id, :task => self}
  end

  def dispatch
  end

  def prevent_update
    raise("Task #{id} was marked as timed out")
  end
end
