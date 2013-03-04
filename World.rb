class World
	attr_accessor :ary, :dimX, :dimY
	def initialize(window)
		@window = window
		@dimX = @window.dimX
		@dimY = @window.dimY
		@ary = makeAirWorld
	end

	def makeAirWorld
		ary = []
		for x in 0...@dimX
			miniAry = []
			for y in 0...@dimY
				miniAry << Air.new(@window, x, y)
			end
			ary << miniAry
		end
		ary
	end

	def each
		@ary.each do |column|
			column.each do |particle|
				yield(particle)
			end
		end
	end

	def update
		for x in 0...@ary.length
			for y in 0...@ary[x].length
				particle = @ary[x][y]
				oldX, oldY = particle.x, particle.y
				particle.update(self)
				newParticle = particle.transform
				particle = newParticle if newParticle
				c = Air
				c = Water if particle.is_a?(Fish)
				@ary[oldX][oldY] = c.new(@window, oldX, oldY)
				@ary[particle.x][particle.y] = particle
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