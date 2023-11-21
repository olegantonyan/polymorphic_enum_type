# frozen_string_literal: true

require_relative "polymorphic_enum_type/version"
require_relative "polymorphic_enum_type/config"

module PolymorphicEnumType
  def belongs_to_polymorphic_enum_type(*args, **kwargs)
    attr = args.first

    belongs_to(*args, **kwargs.merge(polymorphic: true))
    if ActiveRecord::VERSION::MAJOR >= 7
      enum("#{attr}_type", PolymorphicEnumType.config.enum_hash(attr), scopes: false)
    else
      enum("#{attr}_type".to_sym => PolymorphicEnumType.config.enum_hash(attr), _scopes: false)
    end
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
