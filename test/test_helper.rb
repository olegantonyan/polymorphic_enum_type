# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "polymorphic_enum_type"

require "minitest/autorun"

require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, force: true do |t|
    t.string :text

    t.timestamps
  end

  create_table :articles, force: true do |t|
    t.string :text

    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.string :text
    t.bigint  :commentable_id
    t.bigint  :commentable_type

    t.timestamps
  end

end

PolymorphicEnumType.configure do |config|
  config.add :commentable, { 10 => 'Article', 11 => 'Post', 672 => 'SomeNamespace::AnotherArticle' }
end

class Article < ActiveRecord::Base
  has_many :comments, as: :commentable
end

class Post < ActiveRecord::Base
  has_one :comment, as: :commentable
end

class Comment < ActiveRecord::Base
  include PolymorphicEnumType
  belongs_to_polymorphic_enum_type :commentable
end

module SomeNamespace
  class AnotherComment < ActiveRecord::Base
    self.table_name = :comments

    include PolymorphicEnumType
    belongs_to_polymorphic_enum_type :commentable
  end

  class AnotherArticle < ActiveRecord::Base
    self.table_name = :articles

    has_many :comments, as: :commentable, class_name: 'SomeNamespace::AnotherComment'

    def another_method
      text.upcase
    end
  end
end
