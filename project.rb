require './patient'
require './model'
require './prediction'
require 'descriptive_statistics'

# Create the global arrays and models that store the information
@test_patients = Array.new
@training_patients = Array.new
@predictions = Array.new
@patient_weights = Array.new
@model = Model.new

# Print the contents of the chosen array to the console window in a 
# readable format.
def print
	puts "Which list would you like to print? (test or train) "
	choice = $stdin.gets.chomp
	
	if choice == "test"
		puts "Gender\t| Type\t| Weight > 170\t| Infected?"
		puts "-------------------------------------------"
		@test_patients.each do |p|
			puts p.gender + "\t| " + p.blood_type + "\t|\t" +  
					p.weight + "\t| " +  p.infected
		end
	elsif choice == "train"
		puts "Gender\t| Type\t| Weight > 170\t| Infected?"
		puts "-------------------------------------------"
		@training_patients.each do |p|
			puts p.gender + "\t| " + p.blood_type + "\t|\t" +  
					p.weight + "\t| " +  p.infected
		end
	else
		puts "Invalid option, exiting now..."
	end	
end

# Remove the specific blood type information about each Patient, only care
# about positive or negative information.
def edit_blood_type type
	if type[-1,1] == "-"
		return "-"
	elsif type[-1,1] == "+"
		return "+"
	end
end

# Using 170lbs as a threshold, edit the patient's data with either a 
# yes "Y" or a no "N".
def edit_weight weight
	if weight > 170
		return "Y"
	elsif weight <= 170
		return "N"
	end
end

# Used to calculate the prior for the amount of people that have the 
# virus from the set of data.
def get_virus_stats list
	count = 0.0
	if list == "test"
		@test_patients.each do |p|
			if p.infected == "Y"
				count += 1
			end
		end
		return count/@test_patients.length
	elsif list == "train"
		@training_patients.each do |p|
			if p.infected == "Y"
				count += 1
			end
		end
		return count/@training_patients.length
	end
end

# Returns the number of people that have the virus.
def get_virus_count infected
	count = 0.0
	if infected == "Y"
		@training_patients.each do |p|
			if p.infected == "Y"
				count += 1
			end
		end
	elsif infected == "N"
		@training_patients.each do |p|
			if p.infected == "N"
				count += 1
			end
		end
	end
	return count
end

# Returns the likelihood of the specified gender having the virus from
# the set of data.
def get_likelihood_gender virus
	count = 0.0
	if virus == "Y"
		@training_patients.each do |p|
			if p.gender == "female" && p.infected == "Y"	
				count += 1
			end		
		end
		virus_count = get_virus_count("Y")
	elsif virus == "N"
		@training_patients.each do |p|
			if p.gender == "female"	&& p.infected == "N"
				count += 1
			end		
		end
		virus_count = get_virus_count("N")
	end
	return count/virus_count
end

# Returns the likelihood of the specified blood type having the virus
# from the set of data.
def get_likelihood_blood virus
	count = 0.0
	if virus == "Y"
		@training_patients.each do |p|
			if p.blood_type == "+" && p.infected == "Y"	
				count += 1
			end		
		end
		virus_count = get_virus_count("Y")
	elsif virus == "N"
		@training_patients.each do |p|
			if p.blood_type == "+"	&& p.infected == "N"
				count += 1
			end		
		end
		virus_count = get_virus_count("N")
	end
	return count/virus_count
end

# Returns the likelihood of the specified weight class having the 
# virus from the set of data.
def get_likelihood_weight virus
	count = 0.0
	if virus == "Y"
		@training_patients.each do |p|
			if p.weight == "Y" && p.infected == "Y"	
				count += 1
			end		
		end
		virus_count = get_virus_count("Y")
	elsif virus == "N"
		@training_patients.each do |p|
			if p.weight == "Y"	&& p.infected == "N"
				count += 1
			end		
		end
		virus_count = get_virus_count("N")
	end
	return count/virus_count
end

# Predicts the class of each patient based on discriminator
def build_predictions
	count = 1
	@test_patients.each do |p|
		result = Prediction.new

		# Determine likelihood based on gender for prediction
		if p.gender == "male"
			var1_yes = @model.male_virus
			var1_no = @model.male_not_virus
		else
			var1_yes = @model.female_virus
			var1_no = @model.female_not_virus
		end

		# Determine likelihood based on blood type for prediction
		if p.blood_type == "+"
			var2_yes = @model.positive_virus
			var2_no = @model.positive_not_virus
		else
			var2_yes = @model.negative_virus
			var2_no = @model.negative_not_virus
		end

		# Determine likelihood based on weight for prediction
		if p.weight == "Y"
			var3_yes = @model.large_weight_virus
			var3_no = @model.large_weight_not_virus
		else
			var3_yes = @model.small_weight_virus
			var3_no = @model.small_weight_not_virus
		end

		eq1 = (1 - get_virus_stats("test")) * var1_no * var2_no * var3_no
		eq2 = get_virus_stats("test") * var1_yes * var2_yes * var3_yes

		if eq1 > eq2
			result.create(count, p.infected, "N")
		else
			result.create(count, p.infected, "Y")
		end
		@predictions.push(result)
		count += 1
	end
end

# Used to print the predictions for the test patients
def print_predicitons
	puts "\nPatient #  | Infected?\t|  Prediction\t|"
	puts "-------------------------------------------"
	@predictions.each do |p|
		puts "   #{p.id} \t\t #{p.infected}\t\t#{p.prediction}"
	end

	confusion_matrix()
end

# Given the array of Patient Objects, build model.
def build_model
	@model.create(get_likelihood_gender('Y'),get_likelihood_gender('N'),
					get_likelihood_blood('Y'),get_likelihood_blood('N'),
					get_likelihood_weight('Y'),get_likelihood_weight('N'))
end

# Creates the confusion matrix
def confusion_matrix
	actual_no = 0
	predicted_no = 0
	actual_yes = 0
	predicted_yes = 0

	@predictions.each do |p|
		if p.infected == "Y"
			actual_yes += 1
			if p.prediction == "Y"
				predicted_yes += 1
			end
		elsif p.infected =="N"
			actual_no += 1
			if p.prediction == "N"
				predicted_no += 1
			end
		end
	end
	puts """
== Confusion Matrix ==

	yes 	no
____|__________________
    |
yes |   #{actual_yes - (actual_yes - predicted_yes)}\t#{actual_yes - predicted_yes}
    |
no  |   #{actual_no - predicted_no}\t#{actual_no - (actual_no - predicted_no)}
_______________________
"""
end

# Prints the contents of the model
def print_model
	puts """

Priors:
-------------------------------------------
Prior for virus: #{get_virus_stats("train")}
Prior for not virus: #{1 - get_virus_stats("train")}


Likelihoods:
-------------------------------------------

Female given virus: #{@model.female_virus()}
Female given not virus: #{@model.female_not_virus}

Male given virus: #{@model.male_virus}
Male given not virus: #{@model.male_not_virus}

Postive blood type given virus: #{@model.positive_virus}
Postive blood type given not virus: #{@model.positive_not_virus}

Negative blood type given virus: #{@model.negative_virus}
Negative blood type given not virus: #{@model.negative_not_virus}

Weight > 170lbs. given virus: #{@model.large_weight_virus}
Weight > 170lbs. given not virus: #{@model.large_weight_not_virus}

Weight <= 170lbs. given virus: #{@model.small_weight_virus}
Weight <= 170lbs. given not virus: #{@model.small_weight_not_virus}

-------------------------------------------
	"""
end

# Generates statistical information regarding Patient weight for both 
# populations (virus == y && virus == n)
def weight_info 
	weight_info_virus = Array.new
	weight_info_no_virus = Array.new
	count = 0
	@training_patients.each do |p|
		if p.infected == "Y"
			weight_info_virus.push(@patient_weights[count])
		else
			weight_info_no_virus.push(@patient_weights[count])
		end
		count += 1
	end
	puts """
Patient Weight Info Given Virus:
-----------------------------------
Sum of Patient Weight:\t\t\t#{weight_info_virus.sum}
Mean of Patient Weight:\t\t\t#{weight_info_virus.mean}
Variance of Patient Weight:\t\t#{weight_info_virus.variance}
Standard Deviation of Patient Weight:\t#{weight_info_virus.standard_deviation}

Patient Weight Info Given Not Virus:
-----------------------------------
Sum of Patient Weight:\t\t\t#{weight_info_no_virus.sum}
Mean of Patient Weight:\t\t\t#{weight_info_no_virus.mean}
Variance of Patient Weight:\t\t#{weight_info_no_virus.variance}
Standard Deviation of Patient Weight:\t#{weight_info_no_virus.standard_deviation}
	"""
end

# Open the files and read their contents into the string variables.
test_data = ''
training_data = ''
File.open("proj1test.csv",'r'){ |f| test_data=f.read }
File.open("proj1train.csv",'r'){ |f| training_data=f.read }

# Split the string into an array with each line being its own index 
# in the array.
test_lines = test_data.split("\r\n")
training_lines = training_data.split("\r\n")

# For each item in the array, create a new patient with the values 
# that are separated by commas(,). 
training_lines.each do |line|
	line.gsub!(/\r/,"")
	pat = line.split(",")
	p = Patient.new
	p.create(pat[1],
			edit_blood_type(pat[2].to_s),
			edit_weight(pat[3].to_i),
			pat[4])
	@patient_weights.push(pat[3].to_i)
	@training_patients.push(p)
end

# For each item in the array, create a new patient with the values 
# that are separated by commas(,). 
test_lines.each do |line|
	line.gsub!(/\r/,"")
	pat = line.split(",")
	p = Patient.new
	p.create(pat[1],
			edit_blood_type(pat[2].to_s),
			edit_weight(pat[3].to_i),
			pat[4])
	@test_patients.push(p)
end

# Build the model & predicitons
build_model()
build_predictions()

# Menu options that loop back to let you choose another option
loop do
	puts "\nWhat would you like to do?\n\t- build model?\n\t- print?\n\t- predictions?\n\t- weights?"
	choice = $stdin.gets.chomp
	if choice.downcase == "build model"
		print_model()
	elsif choice.downcase == "print"
		print()
	elsif choice.downcase == "predictions"
		print_predicitons()
	elsif choice.downcase == "weights"
		weight_info()
	else
		puts "Invalid input, exiting now..."
	end
end
