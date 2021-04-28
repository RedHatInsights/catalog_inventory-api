class ApplicationRecord < ActiveRecord::Base
  require 'acts_as_tenant'

  self.abstract_class = true

  def as_json(options = {})
    options[:except] ||= []
    super
  end

  def serializable_hash(options = nil)
    return super(options) unless has_attribute?(self.class.inheritance_column)

    options = options.try(:dup) || {}

    options[:methods]  = Array(options[:methods]).map(&:to_s)
    options[:methods] |= Array(self.class.inheritance_column)

    super(options)
  end

  require 'act_as_taggable_on'
  ActiveSupport.on_load(:active_record) do
    extend ActAsTaggableOn
  end
end
