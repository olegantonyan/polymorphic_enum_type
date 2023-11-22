# frozen_string_literal: true

require "test_helper"

class TestPolymorphicEnumType < Minitest::Test
  def setup
    Comment.destroy_all
    Article.destroy_all
    Post.destroy_all
  end

  def test_config_exists
    assert_equal({ 'Article' => 10, 'Post' => 11, 'SomeNamespace::AnotherArticle' => 672 }, PolymorphicEnumType.config.enum_hash(:commentable))
  end

  def test_polymorphic_has_many
    comment1 = Comment.create(text: '111')
    comment2 = Comment.create(text: '222')
    comment3 = Comment.create(text: '333')

    Article.create(text: 'one comment', comments: [comment1])

    assert_equal 1, Article.find_by(text: 'one comment').comments.count
    assert_equal '111',  Article.find_by(text: 'one comment').comments.first.text

    Article.create(text: 'two comments', comments: [comment2, comment3])

    assert_equal 2, Article.find_by(text: 'two comments').comments.count
    assert_equal '222', Article.find_by(text: 'two comments').comments.first.text
    assert_equal '333', Article.find_by(text: 'two comments').comments.last.text

    assert_equal 1, Article.find_by(text: 'one comment').comments.count
    assert_equal '111', Article.find_by(text: 'one comment').comments.first.text
  end

  def test_polymorphic_has_many_from_another_side
    article1 = Article.create(text: 'another one comment')
    article2 = Article.create(text: 'another two comments')

    Comment.create(text: '1111', commentable: article1)
    Comment.create(text: '2222', commentable: article2)
    Comment.create(text: '3333', commentable: article2)

    assert_equal 1, Article.find_by(text: 'another one comment').comments.count
    assert_equal '1111', Article.find_by(text: 'another one comment').comments.first.text

    assert_equal 2, Article.find_by(text: 'another two comments').comments.count
    assert_equal '2222', Article.find_by(text: 'another two comments').comments.first.text
    assert_equal '3333', Article.find_by(text: 'another two comments').comments.last.text
  end

  def test_polymorphic_has_one
    comment1 = Comment.create(text: '11111')
    comment2 = Comment.create(text: '22222')

    Post.create(text: 'one comment', comment: comment1)

    assert_equal '11111', Post.find_by(text: 'one comment').comment.text

    Post.create(text: 'two comment', comment: comment2)

    assert_equal '11111', Post.find_by(text: 'one comment').comment.text
    assert_equal '22222', Post.find_by(text: 'two comment').comment.text

    Post.create(text: 'no comment')
    assert_nil Post.find_by(text: 'no comment').comment
  end

  def test_polymorphic_has_one_from_another_side
    post1 = Post.create(text: 'yet another one comment')
    post2 = Post.create(text: 'yet another two comment')

    Comment.create(text: '111_111', commentable: post1)

    assert_equal '111_111', Post.find_by(text: 'yet another one comment').comment.text

    Comment.find_by(text: '111_111').destroy
    Comment.create(text: '222_222', commentable: post1)

    assert_equal '222_222', Post.find_by(text: 'yet another one comment').comment.text

    Comment.create(text: '333_333', commentable: post2)

    assert_equal '333_333', Post.find_by(text: 'yet another two comment').comment.text
    assert_equal '222_222', Post.find_by(text: 'yet another one comment').comment.text

    Comment.find_by(text: '333_333').destroy
    Comment.create(text: '444_444', commentable: post2)
    assert_equal '444_444', Post.find_by(text: 'yet another two comment').comment.text
    assert_equal '222_222', Post.find_by(text: 'yet another one comment').comment.text
  end

  def test_with_custom_class_name
    comment1 = SomeNamespace::AnotherComment.create(text: '111')
    comment2 = SomeNamespace::AnotherComment.create(text: '222')
    comment3 = SomeNamespace::AnotherComment.create(text: '333')

    SomeNamespace::AnotherArticle.create(text: 'one comment', comments: [comment1])

    assert_equal 1, SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.count
    assert_equal '111', SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.first.text

    SomeNamespace::AnotherArticle.create(text: 'two comments', comments: [comment2, comment3])

    assert_equal 2, SomeNamespace::AnotherArticle.find_by(text: 'two comments').comments.count
    assert_equal '222', SomeNamespace::AnotherArticle.find_by(text: 'two comments').comments.first.text
    assert_equal '333', SomeNamespace::AnotherArticle.find_by(text: 'two comments').comments.last.text

    assert_equal 1, SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.count
    assert_equal '111', SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.first.text

    assert_equal 'ONE COMMENT', SomeNamespace::AnotherComment.find_by(text: '111').commentable.another_method
  end

  def test_queries
    Comment.create(text: 'good', commentable: Post.create(text: '123'))
    artcile = Article.create(text: '1234')
    Comment.create(text: 'good1', commentable: artcile)
    Comment.create(text: 'good2', commentable: artcile)

    assert_equal 1, Comment.where(commentable_type: 'Post').count
    assert_equal 2, Comment.where(commentable_type: 'Article').count

    assert_equal 0, Comment.where("commentable_type = 'Post'").count
    assert_equal 0, Comment.where("commentable_type = 'Article'").count

    assert_equal 1, Comment.where("commentable_type = ?", Comment.commentable_types['Post']).count
    assert_equal 2, Comment.where("commentable_type = ?", Comment.commentable_types['Article']).count
  end
end
