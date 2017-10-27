class BoundingBox
  attr_reader :left, :bottom, :width, :height, :right, :top

  def initialize(left, bottom, width, height)
    @left = left
    @bottom = bottom
    @width = width
    @height = height
    @right = @left + @width
    @top = @bottom + @height
  end

  def collide?(x, y)
    x >= left && x <= right && y >= bottom && y <= top
  end

  def intersects?(box)
    self.right > box.left && self.bottom < box.top && self.left < box.right && self.top > box.bottom
  end
end

