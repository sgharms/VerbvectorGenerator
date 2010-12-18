$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require "verbvector"

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
        def initialize(&b)
          yield
        end
      end
    end
  end
end
