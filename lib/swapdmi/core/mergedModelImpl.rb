
module SwapDmi
	
	#special purpose extension of ModelImpl which combines/merges logic from multiple implemenations
	#
	#
	class MergedModelImpl < ModelImpl
		
		def initialize(id = :unnamed)
			super(id)
			@delegates = []
			@filters = Hash.new do |allFilters, keys| allFilters[keys] = Hash.new do |actionFilters,delegate|
				Proc.new {|*args| true}
			end end
		end

		def delegateTo(*ids)
			@delegates += ids
			@delegates.uniq!
			self
		end
		
		def defineFilterFor(delegate, *keys, &logic)
			@filters[keys][delegate] = logic
			self
		end
		
		def defineExcludeFor(delegate, *keys)
			self.defineFilterFor(delegate, *keys) {|dkey, *args| false}
		end
		
		def defineAlwaysFor(delegate, *keys)
			self.defineFilterFor(delegate, *keys) {|dkey, *args| true}
		end

		def delegates()
			@delegates.dup
		end

		def define(*keys, &logic)
			delegates = @delegates
			filters = @filters[keys]
			
			recv = self
			mlogic = Proc.new do |*args|
				subresults = {}
				delegates.each do |dkey|
					next unless filters[dkey].call(dkey, *args)
					dlogic = SwapDmi::ModelImpl[dkey]
					subresults[dkey] = dlogic[*keys].call(*args)
				end
				recv.instance_exec(args, subresults, &logic)
			end
			
			super(*keys, &mlogic)
		end
	end
	
end
