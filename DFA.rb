class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
  end
end

class DFARulebook < Struct.new(:rules)
  def next_state(state, character)
    rule_for(state, character).follow
  end

  def rule_for(state, character)
    rules.detect { |rule| rule.applies_to?(state, character) }
  end
end

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_state)
  end

  def read_character(character)
    self.current_state = rulebook.next_state(current_state, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def to_dfa
    DFA.new(start_state, accept_states, rulebook)
  end

  def accepts?(string)
    to_dfa.tap { |dfa| dfa.read_string(string) }.accepting?
    # dfa = to_dfa
    # dfa.read_string(string)
    # dfa.accepting?
  end
end

# rulebook = DFARulebook.new([
#   FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
#   FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
#   FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
# ])
# p DFA.new(1, [1, 3], rulebook).accepting?
# p DFA.new(1, [3], rulebook).accepting?
# dfa = DFA.new(1, [3], rulebook)
# p dfa.accepting?
# dfa.read_string('baaab')
# p dfa.accepting?
# dfa_design = DFADesign.new(1, [3], rulebook)
# p dfa_design.accepts?('a')
# p dfa_design.accepts?('baa')
# p dfa_design.accepts?('baba')

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state| follow_rules_for(state, character)}.to_set
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end

  def rules_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) }
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)

    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end

  def alphabet
    rules.map(&:character).compact.uniq
  end
end

require 'set'
class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  # accpet_states NFA是可能的状态集合，DFA是确定状态
  # TODO：做一个函数，accept就创建新的DFA不可以吗，有什么差异  为什么是避免手工操作
  def accepting?
    (current_states & accept_states).any?
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end

  def current_states
    rulebook.follow_free_moves(super)
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(string)
    to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
  end

  def to_nfa(current_states = Set[start_state])
    NFA.new(current_states, accept_states, rulebook)
  end
end

# rulebook = NFARulebook.new([
#   FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
#   FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
#   FARule.new(3, 'a', 4), FARule.new(3, 'b', 4)
#                            ])
# nfa_design = NFADesign.new(1, [4], rulebook)
# p nfa_design.accepts?('bab')
# p nfa_design.accepts?('bbbbb')
# p nfa_design.accepts?('bbabb')
#
# rulebook = NFARulebook.new([
#   FARule.new(1, nil, 2), FARule.new(1, nil, 4), FARule.new(2, 'a', 3),
#   FARule.new(3, 'a', 2),
#   FARule.new(4, 'a', 5),
#   FARule.new(5, 'a', 6),
#   FARule.new(6, 'a', 4)
#                            ])
# p rulebook.next_states(Set[1], nil)
# p rulebook.follow_free_moves(Set[1])
# nfa_design = NFADesign.new(1, [2, 4], rulebook)
# p nfa_design.accepts?('aa')
# p nfa_design.accepts?('aaa')
# p nfa_design.accepts?('aaaaa')
# p nfa_design.accepts?('aaaaaa')




class NFASimulation < Struct.new(:nfa_design)
  def next_state(state, character)
    nfa_design.to_nfa(state).tap { |nfa|
      nfa.read_character(character)
    }.current_states
  end

  def rules_for(state)
    nfa_design.rulebook.alphabet.map { |character|
      FARule.new(state, character, next_state(state, character))
    }
  end

  def discover_states_and_rules(states)
    rules = states.flat_map { |state| rules_for(state) }
    more_states = rules.map(&:follow).to_set

    if more_states.subset?(states)
      [states, rules]
    else
      discover_states_and_rules(states + more_states)
    end
  end

  def to_dfa_design
    start_state = nfa_design.to_nfa.current_states
    states, rules = discover_states_and_rules(Set[start_state])
    accept_states = states.select { |state| nfa_design.to_nfa(state).accepting? }

    DFADesign.new(start_state, accept_states, DFARulebook.new(rules))
  end
end


# rulebook = NFARulebook.new([
#                                FARule.new(1, 'a', 1), FARule.new(1, 'a', 2), FARule.new(1, nil, 2), FARule.new(2, 'b', 3),
#                                FARule.new(3, 'b', 1), FARule.new(3, nil, 2)
#                            ])
#
# nfa_design = NFADesign.new(1, [3], rulebook)
#
# simulation = NFASimulation.new(nfa_design)
# p simulation.next_state(Set[1, 2], 'a')
#
# dfa_design = simulation.to_dfa_design
# p dfa_design.accepts?('aaa')
# p dfa_design.accepts?('aab')
# p dfa_design.accepts?('bbbabb')