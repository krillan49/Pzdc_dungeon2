class Dazed
  BASIC_MOD = 1
  LVL_MOD = 0.1

  attr_accessor :lvl
  attr_reader :code, :name

  def initialize
    @code = 'dazed'
    @name = "Dazed"
    @lvl = 0
  end

  def accuracy_reduce_coef
    BASIC_MOD + LVL_MOD * @lvl
  end

  def accuracy_reduce_percent
    100 / (2 * accuracy_reduce_coef())
  end

  def description
    "(#{@lvl}): if damage is greater #{accuracy_reduce_percent().round}% remaining enemy lives then he loses 10-90(%) accuracy"
  end
end











#
