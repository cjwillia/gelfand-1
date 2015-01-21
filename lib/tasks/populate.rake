namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Need two gems to make this work: faker & populator
    # Docs at: http://populator.rubyforge.org/
    require 'populator'
    # Docs at: http://faker.rubyforge.org/rdoc/
    require 'faker'
    r = Random.new
    # clear any old data in the db
    [Affiliation, BgCheck, Contact, Individual, Membership, OrgUser, Organization, Participant, Program, User].each(&:delete_all)

    STATE_ABBREVIATIONS = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    # create admin user
    admin = User.new
    admin.email = "admin@example.com"
    admin.password = "secretpassword"
    admin.password_confirmation = "secretpassword"
    admin.admin = true
    admin.skip_confirmation!
    admin.member = true
    admin.save!
    # create contact for admin user
    contact = Contact.new
    contact.phone = rand(10 ** 10).to_s.rjust(10,'0')
    contact.email = admin.email
    contact.street = Faker::Address.street_address
    contact.city = Faker::Address.city
    contact.state = STATE_ABBREVIATIONS.sample
    contact.zip = rand(5 ** 5).to_s.rjust(5,'0')
    contact.save!

    # create individual for admin user
    indiv = Individual.new
    indiv.f_name = Faker::Name.first_name
    indiv.l_name = Faker::Name.last_name
    indiv.active = true
    indiv.user_id = admin.id
    indiv.contact_id = contact.id
    indiv.role=2
    indiv.save!

    # create 15 organizations with contact information
    organizations=[]
    15.times do
        contact = Contact.new
        contact.phone = rand(10 ** 10).to_s.rjust(10,'0')
        contact.email = Faker::Internet.email
        contact.street = Faker::Address.street_address
        contact.city = Faker::Address.city
        contact.state = STATE_ABBREVIATIONS.sample
        contact.zip = rand(5 ** 5).to_s.rjust(5,'0')
        contact.save!

        organization = Organization.new
        organization.name = Faker::Lorem.word.capitalize+" "+["Club","Organization","Center"].sample
        organization.description = Faker::Lorem.paragraph
        organization.active = true
        organization.department = ["History","Information Systems", "Computer Science","Engineering","Business","English","Linguistics","Cognitive Science","Art","Architecture","Drama","Philosophy","Psycholog","Statistics","Economics"].sample
        organization.contact_id = contact.id
        organization.save!
        organizations.push organization
    end

    # create 0...5 programs for each organization
    organizations.each do |org|
        rand(6).times do
            contact = Contact.new
            contact.phone = rand(10 ** 10).to_s.rjust(10,'0')
            contact.email = Faker::Internet.email
            contact.street = Faker::Address.street_address
            contact.city = Faker::Address.city
            contact.state = STATE_ABBREVIATIONS.sample
            contact.zip = rand(5 ** 5).to_s.rjust(5,'0')
            contact.save!

            program = Program.new
            program.name = Faker::Lorem.word.capitalize+" "+Faker::Lorem.word.capitalize+" "+["Program","Activity","Day","Event","Days","Events","Programs", "Activities","Week","Weeks","Occurrence","Happening","Contest","Competition","Round","Occasion","Match"].sample
            puts program.name
            program.description = Faker::Lorem.paragraph
            program.start_date = Date.today + r.rand(-50...100)
            program.end_date = program.start_date + r.rand(100)
            program.cmu_facilities = ["Wean Hall","University Center","Porter Hall", "Simon Hall", "Wiegand Gym","Resnik"].sample
            program.off_campus_facilities = ["None","Cathedral of Learning", "Carnegie Science Center"].sample 
            program.num_minors = r.rand(0...150)
            program.num_adults_supervising =  r.rand(0...50)
            program.contact_id = contact.id
            program.save!

            affiliation = Affiliation.new
            affiliation.organization_id = org.id
            affiliation.program_id = program.id
            affiliation.description = Faker::Lorem.sentence
            affiliation.followed_process = [true,false].select
            affiliation.save!
        end

    end

    # create 150 regular users
    150.times do
        f_name = Faker::Name.first_name
        l_name = Faker::Name.last_name

        user = User.new
        user.email = "#{f_name}.#{l_name}@example.com"
        user.password = "secretpassword"
        user.password_confirmation = "secretpassword"
        user.skip_confirmation!
        user.admin = false
        user.member = true
        user.save!

        contact = Contact.new
        contact.phone = rand(10 ** 10).to_s.rjust(10,'0')
        contact.email = user.email
        contact.street = Faker::Address.street_address
        contact.city = Faker::Address.city
        contact.state = STATE_ABBREVIATIONS.sample
        contact.zip = rand(5 ** 5).to_s.rjust(5,'0')
        contact.save!

        indiv = Individual.new
        indiv.f_name = f_name
        indiv.l_name = l_name
        indiv.active = true
        indiv.user_id = user.id
        indiv.contact_id = contact.id
        indiv.role = rand(3)
        indiv.save!

        # Give them a Background Check (2/3 chance)
        
        n = rand(3)

        if n < 2
            bg_check = BgCheck.new
            bg_check.individual_id = indiv.id
            bg_check.status = rand(7)

            # Give it a default date requested
            dr = Date.today - r.rand(15...60)
            bg_check.date_requested = dr

            # Exclude the just created case
            if bg_check.status > 1
                # If it's expired, give it old dates
                if bg_check.status == 6
                    old = Date.today << r.rand(60...100)
                    bg_check.date_requested = old - r.rand(2...8)
                    bg_check.criminal_date = old
                    bg_check.child_abuse_date = old + r.rand(2...15)
                else
                    # If things have cleared, give it clearance dates
                    if bg_check.status < 5
                        bg_check.criminal_date = dr + r.rand(2...5)

                        # If they got the child abuse date, assign it some time after the criminal date
                        if bg_check.status > 2
                            bg_check.child_abuse_date = dr + r.rand(6...13)
                        end
                    else
                        # If they are not cleared, uh..... This should work already???
                        if bg_check.status == 5

                        # This would be an error.
                        else

                        end
                    end 
                end
            end
            bg_check.save!
        end
        
        # Have them be members of 0...4 orgs
        # BUG: user can be added to the same organization twice.
        rand(5).times do
            membership = Membership.new
            org = organizations.sample
            membership.individual_id = indiv.id
            membership.organization_id = org.id
            membership.active = true
            membership.save!


            # Select some programs for the individual to sign up for
            org_programs = org.programs.sample(rand(org.programs.count))

            org_programs.each do |program|
                participant = Participant.new
                participant.individual_id = indiv.id
                participant.program_id = program.id
                participant.save!
            end
        end
    end

    # Now that we have organizations with users in them, make one member the Organization Head

    organizations.each do |org|
        leader = org.individuals.sample
        org_user = OrgUser.new
        org_user.organization_id = org.id
        org_user.user_id = leader.user.id
        org_user.save!
    end
  end
end
