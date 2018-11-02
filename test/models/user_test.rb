require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
  	@user = User.new(name: "Example User", email: "user@example.com", 
  										password: "123456", password_confirmation: "123456")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = "   "
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "   "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = %w[user@example.com USER@foo.COM A_US@foo.bar.org first.last@foo.jp alicebob@baz.cn]
  	valid_addresses.each do |a|
  		@user.email = a
  		assert @user.valid?, "#{a.inspect} should be valid"
  	end
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "email addresses should be saved in lower-case" do
  	mixed_case_email = "Foo@ExAmPlE.CoM"
  	@user.email = mixed_case_email
  	@user.save
  	assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
  	@user.password = @user.password_confirmation = " " * 6
  	assert_not @user.valid?
  end

  test "password should have a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do 
    @user.save
    @user.microposts.create!(content: "123")
    assert_difference 'Micropost.count', -1 do 
      @user.destroy
    end
  end

  test "should follow and unfollow users" do 
    example = users(:Example)
    archer = users(:Archer)
    example.unfollow(archer)
    assert_not example.following?(archer)
    example.follow(archer)
    assert example.following?(archer)
    assert archer.followers.include?(example)
    example.unfollow(archer)
    assert_not example.following?(archer)
  end

  test "feed should have the right posts" do 
    example = users(:Example)
    archer = users(:Archer)
    lana = users(:Lana)
    
    lana.microposts.each do |post_following|
      assert example.feed.include?(post_following)
    end

    example.microposts.each do |post_self|
      assert example.feed.include?(post_self)
    end

    archer.microposts.each do |post_unfollowed|
      assert_not example.feed.include?(post_unfollowed)
    end

  end
  
end
