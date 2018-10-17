require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
	def setup
		ActionMailer::Base.deliveries.clear
		@user = users(:Example)
	end

	test "password resets" do 
		get new_password_reset_path
		assert_template 'password_resets/new'
		#empty email
		post password_resets_path, params: { password_reset: {email: ""} }
		assert_not flash.empty?
		assert_template 'password_resets/new'
		#check for sending email if users email correct
		post password_resets_path, params: { password_reset: { email: @user.email} }
		assert_not_equal @user.reset_digest, @user.reload.reset_digest
		assert_equal 1, ActionMailer::Base.deliveries.size
		assert_not flash.empty?
		assert_redirected_to root_url

		user = assigns(:user)
		#empty email
		get edit_password_reset_path(user.reset_token, email: "")
		assert_redirected_to root_url

		user.toggle!(:activated)
		get edit_password_reset_path(user.reset_token, email: user.email)
		assert_redirected_to root_url
		user.toggle!(:activated)
		#incorrect reset token
		get edit_password_reset_path("crap", email: user.email)
		assert_redirected_to root_url
		#checking for hidden input field
		get edit_password_reset_path(user.reset_token, email: user.email)
		assert_template 'password_resets/edit'
		assert_select "input[name=email][type=hidden][value=?]", user.email
		#different passwords
		patch password_reset_path(user.reset_token),
		params: { email: user.email, 
			user: { password: "foobaz", password_confirmation: "barquua" } }
		assert_select 'div#error_explanation'
		#everything all right
		patch password_reset_path(user.reset_token),
		params: { email: user.email, 
			user: { password: "foobaz", password_confirmation: "foobaz" } }
		assert is_logged_in?
		assert_not flash.empty?
		assert_redirected_to user
	end
		
		test "expired token" do 
			get new_password_reset_path
			post password_resets_path, params: { password_reset: { email: @user.email} }
			@user = assigns(:user)
			@user.update_attribute(:reset_sent_at, 3.hours.ago)
			patch password_reset_path(@user.reset_token),
				params: { email: @user.email, 
				user: { password: "foobaz", password_confirmation: "foobaz" } }
			assert_response :redirect
			follow_redirect!
			@user.reload
			assert_match "expired", response.body			
		end

end
