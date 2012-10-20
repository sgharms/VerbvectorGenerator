$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'verbvector'

# Generalized module for handling lingustics processing
module Linguistics
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
        attr_reader :language, :aspect_list, :vector_list, :cluster_methods,
                    :respondable_methods

        # Initialization
        #
        # Takes the descriptive block of the tense structure in a DSL format
        def initialize(&b)
          @aspect_list         = []
          @vector_list         = []
          @respondable_methods = []
          @cluster_methods     = {}
          @language            = ""

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
          instance_eval(&b)

          @aspect_list.sort!
        end

        # Vectors are specified at their most atomic
        # Sometimes it is handy to return all the values that match
        # "up to" a given aspect and then uniq'ify them

        def match_vector_upto_aspect(s)
          @vector_list.compact.sort.grep(/#{s}/).map{ |x|
            x.sub(/(^.*#{s}).*/,%q(\1))
          }.uniq
        end

        # Creates the anonymous module based on the contents of @vector_list.
        # The method names in this module are just stubs _except_ those that
        # are loaded into the @cluster_methods hash.  By generating all the
        # method names we allow +responds_to?+ to work as expected.

        def method_extension_module
          v = @vector_list
          c = @cluster_methods
          l = @language
          r = @respondable_methods

          Module.new do
            # This defines instance methods on the Module
            # m.instance_methods #=> [:say_foo, :say_bar, :say_bat]

            # Note, you can't use @someArray in the iteration because
            # self has changed to this anonymous module.  Since a block
            # is a binding, it has the local context (including 'v')
            # bundled up with it -- despte self having changed!
            # Therefore, the following works.

            # Define a method for each name in vector_list.
            raise("Language was not defined." ) if l.nil?

            v.each do |m|
              r << "#{m}"
              define_method "#{l.downcase}_#{m}".to_sym do
              end
            end

            # Write something to spit out the vectors as well.
            define_method :vector_list do
              return v
            end

            define_method :respondable_methods do
              return r
            end

            # Spit out the clustered methods
            c.each_pair do |k,val|
              define_method k do
                val.call
              end
            end

          end
        end

        # Language takes a symbol for +l+ the language whose verb we seek to
        # model.  It then takes a block for the sub-specification of the verbs
        # of that language.
        def language(*l,&b)
          return @language if (l[0].nil? and not @language.nil?)
          @language = l[0]
          instance_eval(&b)
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
          @aspect_list.push specification[0]
          @aspect_list.uniq!

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

          instance_eval(&b)
        end

        # Method appends vector definitions _if_ the +condition+ (a RegEx) is satisfied
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
          @aspect_list.push specification[0]
          @aspect_list.uniq!

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

        # Languages are not entirely rational, while something _ought_ exist
        # by the rules of rational combination, some times they simply _don't_
        # exist.  That's what this method is for.
        #
        # +action+ :: +:remove+ or +:add+
        # +id+     :: method name to remove
        # _block_  :: used to add
        def exception(action, id, &b)
          if action == :remove
            @vector_list.delete_if {|x| x =~ /#{id.to_s}/ }
          elsif action == :add
          end
        end

        # Method to take a hash key where the key is an _aspect_ and the value
        # is an array of specifications valid for that _aspect_.
        def combinatorialize(h)
          results = []
          h[1].each do |k|
            results.push "#{k}_#{h[0]}"
          end
          results
        end

        # Method to allow "clusters" of simiar vectors to be identified (see:
        # +match_upto+) based on the 0th string match.  These clusters can be
        # called by the method namd provided as the 2nd argument (0-index)
        #
        # This allows
        # active_voice_indicative_mood_imperfect_tense_singular_number_third_p
        # erson and other such to be 'clustered' as
        # active_voice_indicative_mood_imperfect_tense.  This means the actual
        # method will probably be done in the "cluster" and some sort of
        # secondary logic (method_missing) will do the final resolution
        #
        # Nevertheless, per the logic of this library, by defining all the
        # atomic, we play nice and give respond_to? all the information it
        # needs
        #
        # *Example:*  <tt>cluster_on /active_voice.*third/, "as method", :active_thirds</tt>
        #
        #
        # This means you want to collect several method names that match the Regexp and make them identifiable by a call to the
        # method +active_thirds+
        #
        # Alternatively, you might want to use a String or Symbol (making use of match_upto).
        #
        # *Example:*  <tt>cluster_on :tense, "as method", :tense_list</tt>
        #
        # +match+  :: The String or Regex match_upto will use for matching
        # +junk+          :: Syntactic sugar, a string that makes the DSL look sensible
        # +method_name+   :: The method in the anonymous module that returns the matched method names.  See +create_module+
        def cluster_on(match, junk, method_name)

          clustered_matches =
            if match.class == Regexp
              @vector_list.grep match
            elsif match.class.to_s =~ /^(String|Symbol)/
              # Get the items that match_upto the specified clustering token
              match_vector_upto_aspect(match.to_s)
            else
              # This shouldn't happen, we should get a Regexp or a String/Symbol
              raise "Didn't fire for clustered match: #{match}"
            end

          unless clustered_matches.nil?
            # No, this should not be done:
            #                    ...and add them to the @vector_list.
            #                    @vector_list += clustered_matches
            # Clustered methods need to be defined, for real, somewhere.  We
            # should not claim to respond to them here, but rather let the
            # framework using verbvector have the responsibility for
            # implementation.


            # Now, define a Proc that can correspond to arg[2]
            @cluster_methods[method_name] = Proc.new do
              clustered_matches
            end
          end
        end
      end
    end
  end
end
