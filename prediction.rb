# Class that holds data about predictions
class Prediction
 	def create(id, infected, prediction) 
 		@id = id
 		@infected = infected
 		@prediction = prediction
 	end

 	# Get the ID
 	def id
 		@id
 	end

 	# Get infected status
 	def infected
 		@infected
 	end

 	# Get prediction
 	def prediction
 		@prediction
 	end
end