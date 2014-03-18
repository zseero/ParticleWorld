class Particle
	attr_accessor :transform, :behind
	def initialize(window, x, y)
		@window = window
		@x, @y = x, y
		@color = 0xff8f8f8f
		@transform = nil
		@behind = nil
	end

	def getX; @x; end
	def getY; @y; end

	def gravity(world)
		if @y > 0 && world.ary[@x][@y - 1].is_a?(Air)
			@y -= 1
			true
		else
			false
		end
	end

	def real?
		true
	end

	def air?
		false
	end

	def update(world)
		gravity(world)
	end

	def draw
		size = @window.size
		x = @x * size
		y = @window.height - ((@y + 1) * size)
		@window.draw_quad(x, y, @color,
											x + size, y, @color,
											x + size, y + size, @color,
											x, y + size, @color,
											Layers::Particles)
	end
end

class Air < Particle
	$classes << self
	def real?
		false
	end
	def air?
		true
	end
	def update(world)
	end
	def draw
	end
end