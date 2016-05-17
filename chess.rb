require 'byebug'
class Board

  BLANK_BOARD =  Array.new(8) { Array.new(8) }
  ALPHABET = ('A'..'Z').to_a

  attr_reader :board

  def self.populate_grid(board)
    #Come back and update
    board.each_with_index do |row, row_index|
      next if row_index.between?(2, 5)
      row.each_with_index do |position, position_idx|
        if row_index < 2
          board[row_index][position_idx] = Pawn.new("white", [row_index, position_idx])
        else
          board[row_index][position_idx] = Piece.new("black", [row_index, position_idx])
        end
      end
    end
  end

  def initialize
    @board = Board.populate_grid(BLANK_BOARD)
  end

  def move(start_pos, end_pos)
    piece = board[start_pos]
    piece.valid_move?(end_pos)
    raise "Invalid Move" if piece == :empty
    board[start_pos] = :empty
    board[end_pos] = piece
  end

  def display
    header = (0...8).to_a.join("  ")
    p "  #{header}"
    board.each_with_index { |row, i| display_row(row, i) }
  end

  def display_row(row, i)
    chars = row.map do |el|
      if el
        el.color
      else
        :empty
      end
    end
    p "#{ALPHABET[i]} #{chars.join(" ")}"
  end

  def empty?(pos)
    row, col = pos
    board[row][col] == nil
  end

  def rows
    board.each
  end

  def [](pos)
    row, col = pos
    board[row][col]
  end

  def []=(pos, val)
    row, col = pos
    val = board[row][col]
  end

  def in_bounds?(pos)
    row, col = pos
    [row, col].all? { |term| term.between?(0, 7)}
  end

end

class Piece

  attr_reader :color
  attr_accessor :position

  def initialize(color, position)
    @color = color
    @position = position
  end

  def to_s
    color
  end

end

class Sliding_Piece < Piece

  attr_reader :type

  def initialize(color, type, position)
    super(color, position)
    @type = type
  end

  def move_dirs
    case type
    when :Q
      moves = [[1, 0], [0, 1], [0, -1], [-1, 0], [1, 1], [-1, -1], [-1, 1], [1, -1]]
    when :R
      moves = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    when :B
      moves = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
    end
  end

  def moves(curr_board)
    start = position
    curr_pos = position
    moves = []
    move_dirs.each do |direction|
      curr_pos = start
      potential_pos = :empty
      while true
        next_pos = curr_pos.map.with_index { |e, i| e + direction[i] }
        break unless curr_board.in_bounds?(next_pos)
        potential_pos = curr_board[next_pos]
        if curr_board.empty?(next_pos)
          moves << next_pos
          curr_pos = next_pos
        else
          moves << next_pos unless potential_pos.color == self.color
          break
        end
      end
    end
    moves
  end
end


class Stepping_Piece < Piece

  attr_reader :type

  def initialize(color, type, position)
    super(color, position)
    @type = type
  end

  def move_dirs
    case type
    when :King
      moves = [[1, 0], [0, 1], [0, -1], [-1, 0], [1, 1], [-1, -1], [-1, 1], [1, -1]]
    when :Knight
      moves = [[-1, -2], [-2, -1], [-2, 1],
      [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2]]
    end
  end

  def moves(curr_board)
    start = position
    moves = []
    move_dirs.each do |direction|
      curr_pos = start
      next_pos = curr_pos.map.with_index { |e, i| e + direction[i] }
      potential_pos = curr_board[next_pos]
      if curr_board.empty?(next_pos)
        moves << next_pos
      else
        moves << next_pos unless potential_pos.color == self.color
      end
    end
    moves.select { |move| curr_board.in_bounds?(move) }
  end

end

class Pawn < Piece

  def initialize(color, position)
    super(color, position)
    @type = :p
    @moved_already = false
  end

  def move_dirs
    case @moved_already
    when true
      [1, 0]
    when false
      [[2, 0], [1, 0]]
    end
  end

  def moves(curr_board)
    start = position
    moves = []
    poss_moves = move_dirs
    diagonals = things_to_attack(position, curr_board)
    poss_moves += diagonals if diagonals
    poss_moves.each do |direction|
      curr_pos = start
      next_pos = curr_pos.map.with_index { |e, i| e + direction[i] }
      potential_pos = curr_board[next_pos]
      if curr_board.empty?(next_pos)
        moves << next_pos
      else
        moves << next_pos unless potential_pos.color == self.color
      end
    end
    moves.select { |move| curr_board.in_bounds?(move) }
  end

  def things_to_attack(pos, curr_board)
    row, col = pos
    left_pos = curr_board.empty?([row + 1, col - 1])
    right_pos = curr_board.empty?([row + 1, col + 1])
    if !left_pos && !right_pos
      [[1, -1], [1, 1]]
    elsif !right_pos
      [1, 1]
    elsif !left_pos
      [1, -1]
    else
      nil
    end
  end
end

require_relative "cursorable"
require "colorize"


class Display
  include Cursorable

  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
  end

  def build_grid
    @board.rows.map.with_index do |row, i|
      build_row(row, i)
    end
  end

  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = colors_for(i, j)
      piece.to_s.colorize(color_options)
    end
  end

  def colors_for(i, j)
    if [i, j] == @cursor_pos
      bg = :light_red
    elsif (i + j).odd?
      bg = :light_blue
    else
      bg = :blue
    end
    { background: bg, color: :white }
  end

  def render
    system("clear")
    puts "Fill the grid!"
    puts "Arrow keys, WASD, or vim to move, space or enter to confirm."
    build_grid.each { |row| puts row.join }
    get_input
    build_grid.each { |row| puts row.join }
  end
end




a = Board.new
a.display
piece = a[[1, 0]]
p piece.moves(a)
b = Display.new(a)
b.render
