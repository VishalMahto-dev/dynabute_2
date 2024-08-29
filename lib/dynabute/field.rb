require 'dynabute/util'
require 'dynabute/joins'

module Dynabute
  class Field < ActiveRecord::Base
    include Joins::Field
    def self.table_name_prefix; Util.table_name_prefix; end
    TYPES = %w(string integer boolean datetime select textarea text url email)
    validates :value_type, inclusion: {in: TYPES}
    validates :name, presence: true, uniqueness: { scope: :target_model }
    validates_presence_of :target_model
    has_many :options, class_name: 'Dynabute::Option', dependent: :destroy, inverse_of: 'field'
    accepts_nested_attributes_for :options, allow_destroy: true

    scope :for, ->(klass){ where(target_model: klass) }

    def value_class
      Util.value_class_name(value_type).safe_constantize
    end

    def self.value_types
      TYPES
    end

    private
    def self.get_parent_class_name
      all.where_clause.binds.detect{|w| w.name == 'target_model'}.try(:value)
    end
  end
end
