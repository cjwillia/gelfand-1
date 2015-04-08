namespace :db do
	desc "Update Background Check Expirations"
	task :bg_checks_update => :environment do
		bg_checks = BgCheck.all
		bg_checks.each do |check|
			if check.update_expired?
				check.save!
				puts "Background Check Auto-Updated for Expiration Date"
			end
		end	
	end
end