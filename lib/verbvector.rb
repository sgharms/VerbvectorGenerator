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
        attr_reader :tense_list, :language
        
        class << self
        end
        
        # Initialization
        #
        # Takes the descriptive block of the tense structure in a DSL format
        def initialize(&b)
          @tense_list = []
          @language   = ""
          
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
        end
        
        # Language takes a symbol for +l+ the language whose verb we seek to
        # model.  It then takes a block for the sub-specification of the verbs
        # of that language.
        def language(l,&b) 
          @language = l
          # debugger
          instance_eval &b
        end
        
        # Used to take a hash that has as key the verbal aspect that is under
        # consideration.  As values it has all the possible values that that
        # aspect can take.  This is a wrapping method onto +start_with+ and
        # +end_with+
        def all_vectors(position,&b)
          pp combinatorialize(yield)
          
        end
        
        def combinatorialize(h)
          results = []
          h.each_pair do |k,v|
            v.each do |mode|
              results.push "#{mode}_#{k}"
            end
          end
          results
        end
      end
    end
  end
end
