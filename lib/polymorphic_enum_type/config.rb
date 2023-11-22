# frozen_string_literal: true

module PolymorphicEnumType
  class Config
    def initialize
      @h = {}
    end

    def add(attr, hash)
      raise "#{attr} already exists" if h[attr.to_sym]

      h[attr.to_sym] = hash
    end

    def enum_hash(attr)
      h.fetch(attr.to_sym)
    end

    private

    attr_reader :h
  end
end
