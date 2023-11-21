# frozen_string_literal: true

require "test_helper"

class TestPolymorphicEnumType < Minitest::Test
  def setup
    Comment.destroy_all
    Article.destroy_all
    Post.destroy_all
  end

  def test_polymorphic_has_many
    comment1 = Comment.create(text: '111')
    comment2 = Comment.create(text: '222')
    comment3 = Comment.create(text: '333')

    Article.create(text: 'one comment', comments: [comment1])

    assert Article.find_by(text: 'one comment').comments.count == 1
    assert Article.find_by(text: 'one comment').comments.first.text == '111'

    Article.create(text: 'two comments', comments: [comment2, comment3])

    assert Article.find_by(text: 'two comments').comments.count == 2
    assert Article.find_by(text: 'two comments').comments.first.text == '222'
    assert Article.find_by(text: 'two comments').comments.last.text == '333'

    assert Article.find_by(text: 'one comment').comments.count == 1
    assert Article.find_by(text: 'one comment').comments.first.text == '111'
  end

  def test_polymorphic_has_many_from_another_side
    article1 = Article.create(text: 'another one comment')
    article2 = Article.create(text: 'another two comments')

    Comment.create(text: '1111', commentable: article1)
    Comment.create(text: '2222', commentable: article2)
    Comment.create(text: '3333', commentable: article2)

    assert Article.find_by(text: 'another one comment').comments.count == 1
    assert Article.find_by(text: 'another one comment').comments.first.text == '1111'

    assert Article.find_by(text: 'another two comments').comments.count == 2
    assert Article.find_by(text: 'another two comments').comments.first.text == '2222'
    assert Article.find_by(text: 'another two comments').comments.last.text == '3333'
  end

  def test_polymorphic_has_one
    comment1 = Comment.create(text: '11111')
    comment2 = Comment.create(text: '22222')

    Post.create(text: 'one comment', comment: comment1)

    assert Post.find_by(text: 'one comment').comment.text == '11111'

    Post.create(text: 'two comment', comment: comment2)

    assert Post.find_by(text: 'one comment').comment.text == '11111'
    assert Post.find_by(text: 'two comment').comment.text == '22222'

    Post.create(text: 'no comment')
    assert Post.find_by(text: 'no comment').comment.nil?
  end

  def test_polymorphic_has_one_from_another_side
    post1 = Post.create(text: 'yet another one comment')
    post2 = Post.create(text: 'yet another two comment')

    Comment.create(text: '111_111', commentable: post1)

    assert Post.find_by(text: 'yet another one comment').comment.text == '111_111'

    Comment.find_by(text: '111_111').destroy
    Comment.create(text: '222_222', commentable: post1)

    assert Post.find_by(text: 'yet another one comment').comment.text == '222_222'

    Comment.create(text: '333_333', commentable: post2)

    assert Post.find_by(text: 'yet another two comment').comment.text == '333_333'
    assert Post.find_by(text: 'yet another one comment').comment.text == '222_222'

    Comment.find_by(text: '333_333').destroy
    Comment.create(text: '444_444', commentable: post2)
    assert Post.find_by(text: 'yet another two comment').comment.text == '444_444'
    assert Post.find_by(text: 'yet another one comment').comment.text == '222_222'
  end

  def test_with_custom_class_name
    comment1 = SomeNamespace::AnotherComment.create(text: '111')
    comment2 = SomeNamespace::AnotherComment.create(text: '222')
    comment3 = SomeNamespace::AnotherComment.create(text: '333')

    SomeNamespace::AnotherArticle.create(text: 'one comment', comments: [comment1])

    assert SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.count == 1
    assert SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.first.text == '111'

    SomeNamespace::AnotherArticle.create(text: 'two comments', comments: [comment2, comment3])

    assert SomeNamespace::AnotherArticle.find_by(text: 'two comments').comments.count == 2
    assert SomeNamespace::AnotherArticle.find_by(text: 'two comments').comments.first.text == '222'
    assert SomeNamespace::AnotherArticle.find_by(text: 'two comments').comments.last.text == '333'

    assert SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.count == 1
    assert SomeNamespace::AnotherArticle.find_by(text: 'one comment').comments.first.text == '111'

    assert SomeNamespace::AnotherComment.find_by(text: '111').commentable.another_method == 'ONE COMMENT'
  end
end
