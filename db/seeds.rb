User.create!(name: "Kavo Greko", 
			 email: "kavogreko@mail.com", 
			 password: "jopa123", 
			 password_confirmation: "jopa123",
			 admin: true,
			 activated: true,
			 activated_at: Time.zone.now)

99.times do |n|
	name = Faker::Name.name
	email = "example-#{n+1}@example.com"
	password = "password"
	User.create!(name: name, 
		email: email, 
		password: password, 
		password_confirmation: password,
		activated: true,
		activated_at: Time.zone.now)
end
