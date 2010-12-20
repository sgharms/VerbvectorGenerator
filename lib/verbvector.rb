$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require "verbvector"
require 'pp'

# Generalized module for handling lingustics processing
module Lingustics
  # Generalized module related to the conjugation of verbs
  module Verbs
    # Each language's specific verb conjugation can be described in terms of a
    # verbal vector, the particular intersection of its voice, tense, number,
    # and person.
    module Verbvector
      # A class designed to generate a module that can be mixed in into a
      # given type of verb (French, Latin, Spanish).  I'm not trying to be
      # obscure, but I'm trying to be very generalizable.
      class VerbvectorGenerator
        attr_reader :tense_list, :language, :aspects
        
        class << self
        end
        
        # Initialization
        #
        # Takes the descriptive block of the tense structure in a DSL format
        def initialize(&b)
          @aspects     = []
          @vector_list = []
          @tense_list  = []
          @language    = ""
          
          # Let's remember the difference between instance_ and class_eval.
          #
          # "class_eval sets things up as if you were in the body of a class
          # definition, so method definitions will define instance methods:"
          #
          # "instance_eval on a class acts as if you were working inside the
          # singleton class of self. Therefore, any methods you define will
          # become class methods." - prog ruby 1.9 v3, prag programmers p.388
          #          
          # As such, instance_eval here is about to apply this eval to the
          # eigenclass.  That means any instance of this class will have this
          # method.
          instance_eval &b
          
          @aspects.sort!
          @tense_list = match_vector_upto_aspect "tense"
          
        end
                
        # Vectors are specified at their most atomic, and therefore most
        # brief.  Sometimes it is handy to return all the values that match
        # "up to" a given aspect and then uniq'ify them
        def match_vector_upto_aspect(s)
            @vector_list.sort.grep(/#{s}/).map{ |x| 
              x.sub(/(^.*#{s}).*/,"#{$1}")
            }.uniq.compact.delete_if {|x| x !~ /\w/}
        end
        
        # Language takes a symbol for +l+ the language whose verb we seek to
        # model.  It then takes a block for the sub-specification of the verbs
        # of that language.
        def language(l,&b) 
          @language = l
          instance_eval &b
        end
        
        # Method generates tense vectors based on aspects that are assumed to
        # apply to all possible vectors.  These would be seen as the most
        # general aspects possible  For example, while only *some* vectors are
        # present tense, *all* vectors have a voice.

        def all_vectors(position,&b)
          # Make sure there is a block given
          return unless (block_given? or yield.first)
          
          # Sentinel condition for stopping recursive call
          return @vector_list unless yield.first
          
          # Provided that there was a block, collect the DSL hash into
          # specifications
          specifications = yield
          
          # Extract the first k/v
          specification = specifications.first

          # Based on the key for each row, take that content and postpend
          # it.to_s to the ending of each value held in the hash element value
          expanded_specification = combinatorialize(specification)
          
          # Remove the expanded value from the specifications hash
          specifications.delete(specification[0])   
          
          # Keep a record of aspects we have seen
          @aspects.push specification[0]
          @aspects.uniq!
          
          # If it's the first go round put the first set of values in.  In
          # general these should be the leftmost and theremfore most general
          if @vector_list.empty? 
            @vector_list = expanded_specification 
          else
            # If there's already a definition in the tens list, for each of
            # the _existing_ values add the array of strings seen in
            # expanded_specifications thereunto.  Hold them in 'temp' and then
            # set @vector_list to temp.
            temp = []
            @vector_list.each do |base|
              expanded_specification.each do |u|
                temp.push base+"_#{u}"
              end
            end
            @vector_list = temp
          end
          
          # Recursive call, sentnel contition is at the top of the method
          all_vectors(position) do
            specifications
          end
          
          instance_eval &b
        end
        
        # Method appends vector definitions /if/ the +condition+ (a RegEx) is satisfied
        def vectors_that(condition,&b)
          matching_stems = @vector_list.grep condition
          temp = []
          
          specifications = yield
          
          # Extract the first k/v
          specification = specifications.first

          # Based on the key for each row, take that content and postpend
          # it.to_s to the ending of each value held in the hash element value
          expanded_specification = combinatorialize(specification)
          
          # Remove the expanded value from the specifications hash
          specifications.delete(specification[0])   

          # Keep a record of aspects we have seen
          @aspects.push specification[0]
          @aspects.uniq!
          
          # So we grepped the desired stems and stored them in matching_stems
          # First we delete those stems (becasue we're going to further specify) them
          matching_stems.each do |x| 
            @vector_list.delete x
            expanded_specification.each do |u|
              temp.push x+"_#{u}"
            end
          end
          
          # Combine the original list with the freshly expanded list
          @vector_list = (@vector_list + temp).sort
        end
        
        
        def combinatorialize(h)
          results = []
          h[1].each do |k|
            results.push "#{k}_#{h[0]}"
          end
          results
        end
        
      end
    end
  end
end
