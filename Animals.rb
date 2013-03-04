class Fish < Particle
	def initialize(window, x, y)
		super(window, x, y)
		@color = 0xff888888
		@counter = 0
	end
	def getDepth(world)
		i = 0
		while world.ary[@x][@y + i].is_a?(Water)
			puts i
			i += 1
		end
		i
	end
	def getAltitude(world)
		i = 0
		while world.ary[@x][@y - i].is_a?(Water)
			i += 1
		end
		i
	end
	def update(world)
		xc = Random.rand(-1..1)
		yc = 0
		if @counter > 10
			yc = Random.rand(-1..1)
			yc = -1 if getDepth(world) < 5
			yc = 1 if getAltitude(world) < 5
			@counter = 0
		end
		x, y = @x + xc, @y + yc
		if @window.valid?(x, y) && world.ary[x][y].is_a?(Water)
			@x, @y = x, y
		end
		@counter += 1
	end
end