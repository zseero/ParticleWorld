require 'rubygems'
require 'gosu'

$index = 0
$classes = []

module Layers
	Background, Particles = *0...2
end

class Window < Gosu::Window
	attr_reader :size, :dimX, :dimY
  def initialize(size, dimX, dimY)
    @size, @dimX, @dimY = size, dimX, dimY
    super(@dimX * @size, @dimY * @size, false, 0)
    self.caption = "Particle World"
    @world = World.new(self)
  	@color = 0xff44ccff
  	@radius = 5
  end

  def needs_cursor?
  	true
  end

  def pixPaint(c, x, y)
  	if valid?(x, y) && (@world.get(x, y).air? || c.name == 'Air')
  		@world.set(x, y, c.new(self, x, y))
  	end
  end

  def paint
  	x, y = mouse_x / @size, (height - mouse_y) / @size
  	x, y, = x.to_i, y.to_i
  	xs = (x - @radius)..(x + @radius)
  	ys = (y - @radius)..(y + @radius)
  	for xx in xs
  		for yy in ys
  			pixPaint($classes[$index], xx, yy) if dist(x, y, xx, yy) < @radius
  		end
  	end
  end

  def dist(x1, y1, x2, y2)
  	Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
  end

  def update
  	if button_down? Gosu::MsLeft
  		paint
  	end
  	@world.update
	end

  def draw
  	printf "\r#{@radius} : #{$classes[$index]}         "
  	draw_quad(0, 0, @color,
  						width, 0, @color,
  						width, height, @color,
  						0, height, @color,
  						Layers::Background)
  	@world.draw
  end

  def valid?(x, y)
  	(x >= 0 && x < @dimX && y >= 0 && y < @dimY)
  end

  def button_down(id)
  	if id == Gosu::KbEscape
  		exit
  	elsif id != Gosu::MsLeft && id != Gosu::MsRight
  		char = button_id_to_char(id)
  		num = char.to_i
  		if char == num.to_s
  			if button_down?(Gosu::KbR)
  				@radius = num * 2
  				@radius = 1 if @radius == 0
  			elsif num < $classes.length
  				$index = num
  			end
  		end
  	end
  end
end

require_relative 'World'
require_relative 'BasicParticles'
require_relative 'Materials'
require_relative 'Plants'
require_relative 'Animals'

ary = []
i = 0
$classes.each do |c|
	ary << "#{i} : #{c.name}"
	i += 1
end
puts ary.join("\n")
puts

window = Window.new(5, 200, 100)
window.show