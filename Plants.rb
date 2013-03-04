class Grass < Sinkable
	def initialize(window, x, y)
		super(window, x, y)
		@color = 0xff00cc00
		@counter = 0
	end
	def toSeed
		if @counter > 10
			if Random.rand(0...100) == 0
				@transform = Trunk.new(@window, @x, @y)
			end
			@counter = 0
		end
		@counter += 1
	end
	def update(world)
		super(world)
		if world.ary[@x][@y + 1].real?
			@transform = Mud.new(@window, @x, @y)
		else
			xs = (@x - 2)..(@x + 2)
			ys = (@y - 2)..(@y + 2)
			alone = true
			for x in xs
				for y in ys
					if @window.valid?(x, y)
						alone = false if world.ary[x][y].is_a?(Trunk)
					end
				end
			end
			toSeed if alone
		end
	end
end

class Trunk < Particle
	def initialize(window, x, y)
		super(window, x, y)
		@color = 0xff885522
		@counter = 0
		@counterThresh = Random.rand(10...50)
		@height = Random.rand(5...10)
		@acceptable = [Air, Trunk, Leaf]
	end
	def height(world)
		i = 0
		while world.ary[@x][@y - i].is_a?(Trunk)
			i += 1
		end
		i
	end
	def update(world)
		super(world)
		if !@acceptable.include?(world.ary[@x][@y + 1].class)
			@transform = Air.new(@window, @x, @y)
		elsif world.ary[@x][@y + 1].air?
			if @counter > @counterThresh
				if height(world) > @height
					xs = -2..2
					ys = -2..2
					for ax in xs
						for ay in ys
							if !(ay < 0 && ax == 0)
								x = @x + ax
								y = @y + ay
								if @window.valid?(x, y)
									world.ary[x][y] = Leaf.new(@window, x, y)
								end
							end
						end
					end
				else
					world.ary[@x][@y + 1] = Trunk.new(@window, @x, @y + 1)
				end
				@counter = 0
			end
		end
		@counter += 1
	end
end

class Leaf < Particle
	def initialize(window, x, y)
		super(window, x, y)
		@color = 0xff00aa00
		@counter = 0
		@counterThresh = Random.rand(10...100)
		@acceptable = [Air, Leaf]
	end
	def update(world)
		if !@acceptable.include?(world.ary[@x][@y + 1].class)
			@transform = Air.new(@window, @x, @y)
		end
	end
end