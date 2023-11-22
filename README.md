# PolymorphicEnumType

[![CI](https://github.com/olegantonyan/polymorphic_enum_type/actions/workflows/ci.yml/badge.svg)](https://github.com/olegantonyan/polymorphic_enum_type/actions/workflows/ci.yml)

Storing class name as a string for each record is bad idea performance-wise. This gem enables `ActiveRecord::Enum` as type column in polymorphic associations. Unlike https://github.com/clio/polymorphic_integer_type this gem does not monkey-patch anything. In fact, all it does is adding `enum` to your model with values as `Hash` where key is your class name and value is integer associated with this class. And that's it, literally a single line of code does the trick.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add polymorphic_enum_type

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install polymorphic_enum_type

## Usage

Extend `PolymorphicEnumType` module in a model with polymorphic `belongs_to` and use `belongs_to_polymorphic_enum_type` instead of `belongs_to`:
```ruby
class Comment < ActiveRecord::Base
  extend PolymorphicEnumType
  belongs_to :commentable, polymorphic: true, enum_type: true
end
```

The database table must have `commentable_type` integer field instead of default string:
```ruby
create_table :comments do |t|
  t.bigint  :commentable_id
  t.bigint  :commentable_type

  ...
end
```

Create initializer, for example `config/initializers/polymorphic_enum_type.rb` and set the mapping integer to class name there:
```ruby
PolymorphicEnumType.configure do |config|
  config.add :commentable, { 1 => 'Article', 2 => 'Post' }
  config.add :imageable, { 1 => 'Comment', 2 => 'User' }
end
```

Note: The mapping here can start from whatever integer you wish, but I would advise not using 0. The reason being that if you had a new class, for instance Avatar, and also wanted to use this polymorphic association but forgot to include it in the mapping, it would effectively get to_i called on it and stored in the database. "Avatar".to_i == 0, so if your mapping included 0, this would create a weird bug.

## Migrating an existing association

If you want to convert a polymorphic association that is already a string, you'll need to set up a migration. (Assuming SQL for the time being, but this should be pretty straightforward.)

```ruby
class CommentsToPolymorphicEnumType < ActiveRecord::Migration

  def up
    change_table :comments do |t|
      t.integer :new_commentable_type
    end

    execute <<-SQL
      UPDATE picture
      SET new_commentable_type = CASE commentable_type
                                   WHEN 'Post' THEN 2
                                   WHEN 'Article' THEN 1
                                 END
    SQL

    change_table :comments, bulk: true do |t|
      t.remove :imageable_type
      t.rename :new_commentable_type, :commentable_type
    end
  end

  def down
    change_table :comments do |t|
      t.string :new_commentable_type
    end

    execute <<-SQL
      UPDATE comments
      SET new_commentable_type = CASE imageable_type
                                   WHEN 2 THEN 'Post'
                                   WHEN 1 THEN 'Article'
                                 END
    SQL

    change_table :pictures, :bulk => true do |t|
      t.remove :commentable_type
      t.rename :new_commentable_type, :commentable_type
    end
  end
end
```

Lastly, you will need to be careful of any place where you are doing raw SQL queries with the string (imageable_type = 'Employee'). They should use the integer instead. However, when using ActiveRecord query methods and passing attributes as symbols there you still have to use strings:

```ruby
Comment.create(text: 'good', commentable: Post.create(text: '123'))
artcile = Article.create(text: '1234')
Comment.create(text: 'good1', commentable: artcile)
Comment.create(text: 'good2', commentable: artcile)

# using where with attr: value syntax works with wtrings - ActiveRecord converts strings to enum values prior to query
assert_equal 1, Comment.where(commentable_type: 'Post').count
assert_equal 2, Comment.where(commentable_type: 'Article').count

# whenever you need to write raw SQL query you have to use integers, since ActiveRecord no longer converts strings to integers for enum in such cases
assert_equal 0, Comment.where("commentable_type = 'Post'").count
assert_equal 0, Comment.where("commentable_type = 'Article'").count

# commentable_types holds hash used for enum
assert_equal 1, Comment.where("commentable_type = ?", Comment.commentable_types['Post']).count
assert_equal 2, Comment.where("commentable_type = ?", Comment.commentable_types['Article']).count
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/olegantonyan/polymorphic_enum_type. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/olegantonyan/polymorphic_enum_type/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PolymorphicEnumType project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/olegantonyan/polymorphic_enum_type/blob/master/CODE_OF_CONDUCT.md).
