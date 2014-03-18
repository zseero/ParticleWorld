class Sinkable < Particle
	def waterGravity(world)
		b2 = false
		if @y > 0 && world.ary[@x][@y - 1].is_a?(Water)
			@y -= 1
			b2 = true
		end
		b2
	end
	def update(world)
		super(world)
		waterGravity(world)
	end
end

class Dirt < Sinkable
	$classes << self
	def initialize(window, x, y)
		super(window, x, y)
		@color = 0xffbb9966
		@counter = 0
	end

	def mud(world)
		@counter += 1
		if @counter > 50
			r = 10
			xs = (@x - r)..(@x + r)
			ys = (@y - r)..(@y + r)
			for x in xs
				for y in ys
					if @window.valid?(x, y)
						@transform = Mud.new(@window, @x, @y) if world.ary[x][y].is_a?(Water) || world.ary[x][y].is_a?(Mud)
					end
				end
			end
			@counter = 0
		end
	end

	def update(world)
		mud(world)
		super(world)
	end
end

class Water < Particle
	$classes << self
	def initialize(window, x, y)
		super(window, x, y)
		@counter = 0
		@color = 0xff0088ff
		@makeAFishCounter = 0
		@makeAFishCounterMax = Random.rand(40..60)#Random.rand(200..400)
	end
	def spill(world)
		if @window.valid?(@x, @y) && world.ary[@x][@y - 1].is_a?(Water)
			xs = [@x - 1, @x + 1]
			for x in xs.shuffle
				if @window.valid?(x, @y) && world.ary[x][@y].is_a?(Air)
					@x += x - @x
					return true
				end
			end
		end
	end
	def makeAFish(world)
		if @makeAFishCounter > @makeAFishCounterMax
			if Random.rand(0...50)
				radius = 10
				range = (radius * -1)..radius
				allWater = true
				for xc in range
					for yc in range
						x, y = @x + xc, @y + yc
						allWater = false if !@window.valid?(x, y) || !world.ary[x][y].is_a?(Water)
					end
				end
				@transform = Fish.new(@window, @x, @y) if allWater
			end
			@makeAFishCounter = 0
		end
		@makeAFishCounter += 1
	end
	def update(world)
		super(world)
		spill(world)
		makeAFish(world)
	end
end

class Mud < Sinkable
	$classes << self
	def initialize(window, x, y)
		super(window, x, y)
		@color = 0xff996633
		@counter = 0
	end
	def toGrass
		if @counter > 10
			if Random.rand(0...5) == 0
				@transform = Grass.new(@window, @x, @y)
			end
			@counter = 0
		end
		@counter += 1
	end
	def update(world)
		super(world)
		toGrass if @window.valid?(@x, @y + 1) && world.ary[@x][@y + 1].air?
	end
end