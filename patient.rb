# Class Representing a single patient
class Patient

	# Create patient object
	def create(gender, blood, weight, infected)
		@gender = gender
		@blood_type = blood
		@weight = weight
		@infected = infected
	end

	# Print the patients info
	def show
		puts @gender+" - "+@blood_type+" - "+@weight+" - "+@infected
	end

	# Get Gender
	def gender
		@gender
	end

	# Get blood type
	def blood_type
		@blood_type
	end

	# Get weight
	def weight
		@weight
	end

	# Get infected status
	def infected
		@infected
	end
end