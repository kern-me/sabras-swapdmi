


#
# cdoe for initializing & setting up SwapDMI, including the dynamic loading based Initializer system
#
#
#

module SwapDmi
	
	#
	# this class is used to define initializers for the framework itself,
	# 	eg. for Rails
	#
	class SwapDmiInit
		extend HasConfig
		
		@@definedInits = {}

		def self.registerInitAs(key)
			@@definedInits[key] = self
			@id = key
		end
		
		def self.id()
			@id
		end
	
		def initialize()
			self.assignId(self.class.id)
		end
		
		def self.invoke(key = nil, args = {})
			initer = self
			unless key.nil?
				root = args[:srcroot]
				root = "swapdmi-init/#{key}" if root.nil?
				Kernel.require(root)
				initer = @@definedInits[key]
			end

			initer.new(key).invoke(args)
		end
		
		def invoke(args = {})
			throw 'unimplemented SwapDmi initialization'
		end
	end
	
	
end




