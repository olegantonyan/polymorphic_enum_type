# frozen_string_literal: true

require_relative "polymorphic_enum_type/version"
require_relative "polymorphic_enum_type/config"

module PolymorphicEnumType
  def belongs_to_polymorphic_enum_type(*args, **kwargs)
    attr = args.first

    belongs_to(*args, **kwargs.merge(polymorphic: true))
    enum("#{attr}_type", PolymorphicEnumType.config.enum_hash(attr), scopes: false)
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
