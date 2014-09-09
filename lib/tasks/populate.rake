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
        organization.is_partner = [true,false].sample
        organization.description = Faker::Lorem.paragraph
        organization.active = true
        organization.department = ["History","Information Systems", "Computer Science","Engineering","Business","English","Linguistics","Cognitive Science","Art","Architecture","Drama","Philosophy","Psycholog","Statistics","Economics"].sample
        organization.contact_id = contact.id
        organization.save!
        organizations.push organization
    end

    # create 0...5 programs for each organization
    programs = []
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
            program.name = Faker::Lorem.word.capitalize + " " +["Program","Activity","Day","Event","Days","Events","Programs", "Activities","Week","Weeks","Occurrence","Happening"].sample
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

      # create individuals that belong to those users 

      # create contact information for those indivs

      # Have them be members of 0...4 orgs

      # If they are a member of an org, have them sign up for some of their programs as participants

      # for 2/3 create a background check, randomizing the status for each
    





    # # Step 2: add some animal types to work with (small set for now...)
    # animals = %w[Dog Cat Ferret Rabbit Bird]
    # animals.sort.each do |animal|
    #   # create an Animal object and assign the name passed into block
    #   a = Animal.new
    #   a.name = animal
    #   # save with bang (!) so exception is thrown on failure
    #   a.save!
    # end
    
    # # Step 3: add some vaccines that PATS will offer
    # vaccines = %w[Leukemia Heartworm Rabies Distemper Parainfluenza]
    # vaccines.sort.each do |vaccine|
    #   # have to do this for each type of animal, so...
    #   animal_ids = Animal.all.map{|a| a.id}
    #   animal_ids.each do |animal_id|
    #     v = Vaccine.new
    #     v.name = vaccine
    #     v.animal_id = animal_id
    #     # assume all durations last 1 year (365 days)
    #     v.duration = 365
    #     v.save!
    #   end
    # end
    
    # # Step 4: add 20 owners to the system and associated pets
    # Owner.populate 20 do |owner|
    #   # get some fake data using the Faker gem
    #   owner.first_name = Faker::Name.first_name
    #   owner.last_name = Faker::Name.last_name
    #   owner.street = Faker::Address.street_address
    #   owner.city = Faker::Address.city
    #   # assume PA since this is a Pittsburgh vet office
    #   owner.state = "PA"
    #   # randomly assign one of four area zip codes
    #   owner.zip = ["15213", "15212", "15090", "15237"]
    #   # want to store phone as 10 digits in db and use rails helper
    #   # number_to_phone to format it properly in views
    #   owner.phone = rand(10 ** 10).to_s.rjust(10,'0')
    #   owner.email = "#{owner.first_name.downcase}.#{owner.last_name.downcase}@example.com"
    #   # assume all the owners still have living pets
    #   owner.active = true
    #   # set the timestamps
    #   owner.created_at = Time.now
    #   owner.updated_at = Time.now
      
    #   # Step 4A: add 1 to 3 pets for each owner
    #   Pet.populate 1..3 do |pet|
    #     pet.owner_id = owner.id
    #     # assign an animal id from ones created in Step 2
    #     pet.animal_id = Animal.all.map{|a| a.id}
    #     # randomly assign a pet name from list of typical pet names
    #     pet.name = %w[Sparky Dusty Caspian Lucky Fluffy Snuggles Snuffles Dakota Montana Cali Polo Buddy Mambo Pickles Pork\ Chop Fang Zaphod Yeller Groucho Meatball BJ CJ TJ Buttercup Bull Bojangles Copper Fozzie Nipper Mai\ Tai Bongo Bama Spot Tango Tongo Weeble]
    #     # randomly assign female status
    #     pet.female = [true, false]
    #     # pick a DOB at random ranging for 12 yrs ago to 1 year ago
    #     pet.date_of_birth = 12.years.ago..1.year.ago
    #     # assume all the pets are alive and active
    #     pet.active = true
    #     # set the timestamps
    #     pet.created_at = Time.now
    #     pet.updated_at = Time.now        
        
    #     # Step 4B: add between 1 to 15 visits for each pet
    #     Visit.populate 1..15 do |visit|
    #       visit.pet_id = pet.id
    #       # set the visit to sometime between DOB and the present
    #       visit.date = pet.date_of_birth..Time.now
    #       # different animals fall in different weight ranges so we need
    #       # to find the right range of weights for the visiting pet
    #       case pet.animal_id
    #       when 1  # birds tend to be between 1 & 2 pounds
    #         weight_range = (1..2) 
    #       when 2  # cats 
    #         weight_range = (5..15)
    #       when 3  # dogs
    #         weight_range = (10..60)
    #       when 4  # ferrets
    #         weight_range = (1..6)
    #       when 5  # rabbits
    #         weight_range = (2..7)
    #       end
    #       # now assign the pet a weight within the range
    #       visit.weight = weight_range
    #       # a couple of blurbing sentences for treatment notes
    #       visit.notes = Populator.sentences(2..10)
    #       # set the timestamps
    #       visit.created_at = Time.now
    #       visit.updated_at = Time.now
          
    #       # Step 4C: add some vaccinations to _some_ of the visits
    #       # Assume that approximately 1 in 3 visits includes a vaccine
    #       get_vaccine = rand(3)  # will generate numbers 0,1,2 at random
    #       if get_vaccine.zero?   # pet's number came up... time for injection
    #         # first, figure out what vaccines this animal can get
    #         # we are using the for_animal named scope written earlier
    #         possible_vaccines = Vaccine.for_animal(pet.animal_id).map{|v| v.id}
    #         # assume that get either 1 or 2 vaccines per visit
    #         Vaccination.populate 1..2 do |vaccination|
    #           vaccination.visit_id = visit.id
    #           vaccination.vaccine_id = possible_vaccines
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
