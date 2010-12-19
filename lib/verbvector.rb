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
          instance_eval &b
        end
        
        # Used to take a hash that has as key the verbal aspect that is under
        # consideration.  As values it has all the possible values that that
        # aspect can take.  This is a wrapping method onto +start_with+ and
        # +end_with+
        def all_vectors(position,&b)
          # return unless block_given? or yield.first
          return @tense_list unless yield.first
          truths = yield
          a_universal = truths.first

          universals = combinatorialize(a_universal)
          truths.delete(a_universal[0])   
          
          if @tense_list.empty? 
            @tense_list = universals 
          else
            temp = []
            @tense_list.each do |base|
              universals.each do |u|

                temp.push base+"_#{u}"
              end
            end
            @tense_list = temp
          end
          
          all_vectors(position) do
            truths
          end
          
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
