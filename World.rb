class World
	attr_accessor :contents, :dimX, :dimY
	def initialize(window)
		@window = window
		@dimX = @window.dimX
		@dimY = @window.dimY
		makeAirWorld
	end

	def makeAirWorld
		@contents = []
		for x in 0...@dimX
			col = []
			for y in 0...@dimY
				col << Air.new(@window, x, y)
				# set x, y, Air.new(@window, x, y)
			end
			@contents << col
		end
	end

	def each
		# @contents.each do |key, particle|
		# 	yield(particle)
		# end
		@contents.each do |col|
			col.each do |particle|
				yield(particle)
			end
		end
	end

	def cToS(x, y)
		"#{x.to_i}:#{y.to_i}"
	end

	def set(x, y, val)
		# @contents[cToS(x, y)] = val
		@contents[x][y] = val
	end

	def get(x, y)
		# @contents[cToS(x, y)]
		@contents[x][y]
	end

	def update
		for x in 0...@dimX
			for y in 0...@dimY
				#particle = @ary[x][y]
				#oldX, oldY = particle.getX, particle.getY
				#particle.update(self)
				#newParticle = particle.transform
				#particle = newParticle if newParticle
				#c = Air
				#c = Water if particle.is_a?(Aquatic) && particle.swimming
				#@ary[oldX][oldY] = c.new(@window, oldX, oldY)
				#@ary[particle.getX][particle.getY] = particle
				particle = get(x, y)
				oldX, oldY = particle.getX, particle.getY
				particle.update(self)
				newParticle = particle.transform
				particle = newParticle if newParticle
				oldParticle = particle.behind
				oldParticle = Air.new(@window, oldX, oldY) if oldParticle.nil?
				set(oldX, oldY, oldParticle)
				particle.behind = get(particle.getX, particle.getY)
				set(particle.getX, particle.getY, particle)
			end
		end
	end

	def draw
		each do |particle|
			particle.draw
			particle
		end
	end
end