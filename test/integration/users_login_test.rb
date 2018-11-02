require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:Example)
  end

  test "login with invalid information followed by logout" do
		get login_path
		post login_path, params: { session: { email: @user.email, password: 'password' } }
		
		assert is_logged_in?
		assert_redirected_to root_url
		follow_redirect!
				
		assert_select "a[href=?]", login_path, count: 0
		assert_select "a[href=?]", logout_path
		assert_select "a[href=?]", user_path(@user)

		delete logout_path
		assert_not is_logged_in?
		assert_redirected_to root_url
		follow_redirect!
		assert_select "a[href=?]", login_path
		assert_select "a[href=?]", logout_path, count: 0
		assert_select "a[href=?]", user_path(@user), count: 0
	end

	test "login with remembering" do
		log_in_as(@user, remember_me: '1')
		assert_not_empty cookies['remember_token']
		assert_equal cookies['remember_token'], assigns(:user).remember_token
	end

	test "login without remembering" do
		log_in_as(@user, remember_me: '1')
		log_in_as(@user, remember_me: '0')
		assert_empty cookies['remember_token']
	end

end
