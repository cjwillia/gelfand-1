FactoryGirl.define do
	factory :individual do
		f_name "John"
		l_name "Doe"
		role 0
		active true
	end

	factory :organization do
		name "Fringe"
		description "A student organization primarily focused on buggy."
		department "Student Activities"
		active true
		is_partner false
	end

	factory :bg_check do
		status 0
		date_requested 10.days.ago
	end

	factory :user do
		email "default@yahoo.com"
		password "password1"
		password_confirmation "password1"
	end
end