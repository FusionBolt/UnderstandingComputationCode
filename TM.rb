class Tape < Struct.new(:left, :middle, :right, :blank)
  def inspect
    "#<Tape #{left.join}(#{middle})#{right.join}>"
  end

  def write(character)
    Tape.new(left, character, right, blank)
  end

  def move_head_left
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :character, :next_state, :write_character, :direction)
  def applies_to?(configuration)
    state == configuration.state && character == configuration.tape.middle
  end

  def follow(configuration)
    TMConfiguration.new(next_state, next_tape(configuration))
  end

  def next_tape(configuration)
    written_tape = configuration.tape.write(write_character)

    case direction
    when :left
      written_tape.move_head_left
    when :right
      written_tape.move_head_right
    end
  end

  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end
end

class DTMRulebook < Struct.new(:rules)
  def applies_to?(configuration)
    !rule_for(configuration).nil?
  end

  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def step
    self.current_configuration = rulebook.next_configuration(current_configuration)
  end

  def run
    step until accepting? || stuck?
  end

  def stuck?
    !accepting? && !rulebook.applies_to?(current_configuration)
  end
end


rulebook = DTMRulebook.new([
                               TMRule.new(1, '0', 2, '1', :right),
                               TMRule.new(1, '1', 1, '0', :left),
                               TMRule.new(1, '_', 2, '1', :right),
                               TMRule.new(2, '0', 2, '0', :right),
                               TMRule.new(2, '1', 2, '1', :right),
                               TMRule.new(2, '_', 3, '_', :left)
                           ])

# p rule = TMRule.new(1, '0', 2, '1', :right)
# p rule.applies_to?(TMConfiguration.new(1, Tape.new([], '0', [], '_')))

p dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
p dtm.run
p dtm.current_configuration
p dtm.accepting?
p dtm.stuck?
