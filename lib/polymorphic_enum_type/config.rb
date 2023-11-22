# frozen_string_literal: true

module PolymorphicEnumType
  class Config
    def initialize
      @h = {}
    end

    def add(attr, hash)
      h[attr.to_sym] = hash
    end

    def enum_hash(attr)
      h.fetch(attr.to_sym).invert
    end

    private

    attr_reader :h
  end
end
