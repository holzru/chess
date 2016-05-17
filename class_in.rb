class Employee

  attr_reader :name, :title, :salary, :boss, :bonus

  def initialize(name, salary, title, boss)
    @name, @title, @salary, @boss  = name, title, salary, boss
  end

  def bonus(multiplier)
    @bonus = @salary * multiplier
  end

end

class Manager < Employee

  attr_accessor :employees

  def initialize(name, salary, title, boss)
    super
    @employees = []
  end

  def bonus(multiplier)
    bonus = []
    employees.each do |employee|
      if employee.is_a?(Manager)
        bonus += [employee.bonus(multiplier) + employee.salary * multiplier]
      else
        bonus << employee.salary * multiplier
      end
    end
    bonus.reduce(:+)
  end
end

if __FILE__ == $PROGRAM_NAME
  Ned = Manager.new("Ned", 1_000_000, "Founder", nil)
  Darren = Manager.new("Darren", 78_000, "TA Manager", Ned)
  Shawna = Employee.new("Shawna", 12_000, "TA", Darren)
  David = Employee.new("Davi", 10_000, "TA", Darren)
  Darren.employees += [Shawna, David]
  Ned.employees += [Darren]
  # p Shawna.bonus(5)
  # p David.bonus(5)
  p Darren.bonus(5)
  p Ned.bonus(5)
end
