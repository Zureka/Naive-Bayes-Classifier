# Model class that holds the values for the likelihoods for use in 
# later calculations.
class Model
	def create(m1, m2, m3, m4, m5, m6)
		@likelihood_female_virus 			= m1
		@likelihood_female_not_virus 		= m2
		@likelihood_male_virus 				= 1 - m1
		@likelihood_male_not_virus 			= 1 - m2
		@likelihood_positive_virus 			= m3
		@likelihood_positive_not_virus		= m4
		@likelihood_negative_virus 			= 1 - m3
		@likelihood_negative_not_virus		= 1 - m4
		@likelihood_large_weight_virus		= m5
		@likelihood_large_weight_not_virus	= m6
		@likelihood_small_weight_virus		= 1 - m5
		@likelihood_small_weight_not_virus	= 1 - m6
	end

	def female_virus
		@likelihood_female_virus
	end

	def female_not_virus
		@likelihood_female_not_virus
	end

	def male_virus
		@likelihood_male_virus
	end

	def male_not_virus
		@likelihood_male_not_virus
	end

	def positive_virus
		@likelihood_positive_virus
	end

	def positive_not_virus
		@likelihood_positive_not_virus
	end

	def negative_virus
		@likelihood_negative_virus
	end

	def negative_not_virus
		@likelihood_negative_not_virus
	end

	def large_weight_virus
		@likelihood_large_weight_virus
	end

	def large_weight_not_virus
		@likelihood_large_weight_not_virus
	end

	def small_weight_virus
		@likelihood_small_weight_virus
	end

	def small_weight_not_virus
		@likelihood_small_weight_not_virus
	end
end