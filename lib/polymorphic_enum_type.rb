# frozen_string_literal: true

require_relative "polymorphic_enum_type/version"
require_relative "polymorphic_enum_type/config"

module PolymorphicEnumType
  def belongs_to_polymorphic_enum_type(*args, **kwargs)
    belongs_to(*args, **kwargs.merge(polymorphic: true))
    enum "#{args.first}_type", PolymorphicEnumType.config.enum_hash(args.first), scopes: false
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
