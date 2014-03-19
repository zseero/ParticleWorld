class Array
	def getImportantTask
		mostImportant = Task.new(:nothing, 0)
		each do |task|
			if task.is_a?(Task)
				mostImportant = task if task.importance > mostImportant.importance
			else
				raise "Array not full of tasks"
			end
		end
		mostImportant
	end
end

class Task
	attr_accessor :name, :importance
	def initialize(name, importance)
		@name = name
		@importance = importance
	end
	def == (obj)
		(@name == obj.name)
	end
end

class Animal < Sinkable
	def initialize(window, x, y, tasks = [])
		super(window, x, y)
		@tasks = tasks
	end
end

class Aquatic < Animal
	def initialize(window, x, y, tasks = [])
		super(window, x, y, tasks)
		@counter = 0
		@color = 0xff888888
	end
	def getDepth(world)
		i = 1
		while @window.valid?(@x, @y + i) && world.get(@x, @y + i).is_a?(Water)
			i += 1
		end
		i
	end
	def getAltitude(world)
		i = 1
		while @window.valid?(@x, @y - i) && world.get(@x, @y - i).is_a?(Water)
			i += 1
		end
		i
	end
	def swim(world)
		xc = Random.rand(-1..1)
		yc = 0
		if @counter > 10
			yc = Random.rand(-1..1)
			yc = -1 if getDepth(world) < 5
			yc = 1 if getAltitude(world) < 5
			@counter = 0
		end
		x, y = @x + xc, @y + yc
		if @window.valid?(x, y) && world.get(x, y).is_a?(Water)
			@x, @y = x, y
		end
		@counter += 1
	end
	def update(world)
		gravity(world)
	end
end

class Fish < Aquatic
	$classes << self
	def initialize(window, x, y, tasks = [])
		super(window, x, y, tasks)
		@color = 0xff88aaaa
		@toFrogCounter = 0
	end
	def update(world)
		super(world)
		if @window.valid?(@x, @y + 1)
			p = world.get(@x, @y + 1)
			if p.real? && !p.is_a?(Water)
				#@transform = Water.new(@window, @x, @y)
			end
		end
		if @window.valid?(@x, @y - 1)
			p = world.get(@x, @y - 1)
			if p.is_a?(Water)
				swim(world)
			end
		end
		if @toFrogCounter > 50
			if Random.rand(0...1000) == 0
				@transform = Frog.new(@window, @x, @y, [Task.new(:toLand, 10)])
			end
		end
		@toFrogCounter += 1
	end
end

class Frog < Aquatic
	$classes << self
	def initialize(window, x, y, tasks = [])
		tasks.to_a << Task.new(:explore, 1)
		super(window, x, y, tasks)
		@color = 0xff118811
		@nearestLand = nil
		@jumpDest = nil
		@jumpStartDifX = nil
		@canFlyThrough = [Air, Water, Trunk, Leaf]
	end
	def explore(world, direction = Random.rand(0..1) * 2 - 1)
		#puts @y
		if @jumpDest
			xDif = @jumpDest.getX - @x
			yDif = @jumpDest.getY - @y
			@jumpStartDifX = xDif if @jumpStartDifX.nil?
			xc = 0
			xc = xDif / xDif.abs if xDif != 0
			x = @x + xc
			@x = x if @window.valid?(x, @y)
			if @jumpStartDifX > xDif * 2 || (yDif > 0 && yDif < 20)
				@y += 1 if @window.valid?(@x, @y + 1)
				return true
			else
				if @canFlyThrough.include?(world.get(@x, @y - 1).class)
					@y -= 1
				else
					@jumpDest = nil
					@jumpStartDifX = nil
				end
			end
		else
			nearbyGrass = []
			radius = 5
			xrange = ((radius * -1)..radius).to_a
			xrange.delete(0)
			xrange.delete_if {|n| n / n.abs != direction}
			for xc in xrange
				for yc in (radius * -1)..(radius)
					x = xc + @x
					y = yc + @y
					if @window.valid?(x, y) && world.get(x, y).is_a?(Grass)
						nearbyGrass << world.get(x, y)
					end
				end
			end
			if nearbyGrass.length > 0
				@jumpDest = nearbyGrass[Random.rand(0...nearbyGrass.length)]
			else
				return false
			end
		end
		true
	end
	def toLand(world)
		if @nearestLand
			@nearestLand = world.get(@nearestLand.getX, @nearestLand.getY)
			if !@nearestLand.is_a?(Grass)
				@nearestLand = nil
			else
				xDif, yDif = (@nearestLand.getX - @x), (@nearestLand.getY + 1 - @y)
				if xDif.abs + yDif.abs < 4
					@x = @nearestLand.getX
					@y = @nearestLand.getY + 1
					@nearestLand = nil
					@tasks.delete(Task.new(:toLand, 0))
				else
					xc = yc = 0
					xc = xDif / xDif.abs if xDif != 0
					yc = yDif / yDif.abs if yDif != 0
					x, y = @x + xc, @y + yc
					@x = x if @window.valid?(x, @y) && world.get(x, @y).is_a?(Water)
					@y = y if @window.valid?(@x, y) && world.get(@x, y).is_a?(Water)
				end
			end
		else
			closestGrass = nil
			world.each do |p|
				if p.is_a?(Grass)
					closestGrass = p if closestGrass.nil? || @window.dist(p.getX, p.getY, @x, @y) < @window.dist(closestGrass.getX, closestGrass.getY, @x, @y)
				end
			end
			@nearestLand = closestGrass
		end
	end
	def toWater(world)
	end
	def update(world)
		gravity(world) if @jumpDest.nil?
		task = @tasks.getImportantTask
		if task.name == :explore
			dir = Random.rand(0..1) * 2 - 1
			bool = explore(world, dir)
			bool2 = explore(world, dir * -1) if !bool
			#@tasks << Task.new(:toLand, 10) if !bool2
		end
		toLand(world) if task.name == :toLand
		#swim(world) if task.name == :swim
		#toWater(world) if task.name == :toWater
	end
end