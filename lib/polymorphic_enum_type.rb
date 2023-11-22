# frozen_string_literal: true

require_relative "polymorphic_enum_type/version"
require_relative "polymorphic_enum_type/config"

module PolymorphicEnumType
  def belongs_to(name, scope = nil, **options)
    if options.delete(:enum_type)
      if ActiveRecord::VERSION::MAJOR >= 7
        enum("#{name}_type", PolymorphicEnumType.config.enum_hash(name), scopes: false, instance_methods: false)
      else
        enum("#{name}_type".to_sym => PolymorphicEnumType.config.enum_hash(name), _scopes: false)
      end
    end

    super(name, scope, **options)
  end

  class << self
    def configure
      yield(config)
    end

    def config
      @config ||= PolymorphicEnumType::Config.new
    end
  end
end
