require 'gosu'
require_relative 'lib/keys'

class Game < Gosu::Window
  include Keys
  SCREEN_HEIGHT = 1000
  SCREEN_WIDTH = 1000

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
  end

  def draw

  end

  def update

  end
end

Game.new.show
