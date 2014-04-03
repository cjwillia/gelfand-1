require 'test_helper'

class IndividualTest < ActiveSupport::TestCase
	# Test Relationships
	should belong_to(:contact)
	should have_many(:participants)
	should have_many(:programs).through(:participants)


  	# Test Validations

  	should validate_presence_of(:f_name)

  	context "Initial Individual Context" do
  		setup do
  			create_individual_context
  		end

  		teardown do
  			remove_individual_context
  		end

  		should "give me dat active user doe" do
  			assert @indiv.active
  		end
	  	
  	end
end
