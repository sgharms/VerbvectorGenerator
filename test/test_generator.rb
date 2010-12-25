require "test/unit"

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require "verbvector"

class TestVerbVector  < Test::Unit::TestCase
  def setup
    @vv = 
    Lingustics::Verbs::Verbvector::VerbvectorGenerator.new do
       language :Latin do
         all_vectors :start_with do
            {
             :voice =>  %w(active passive),
             :mood  =>  %w(indicative subjunctive imperative)
            }
         end
         vectors_that /.*_indicative_mood/ do
           {
             :tense  => %w(present imperfect future
                           perfect pastperfect futureperfect)
           }
         end
         vectors_that /.*_subjunctive_mood/ do
           {
             :tense => %w(present imperfect 
                           perfect pastperfect)
           }
         end
         vectors_that /.*_imperative_mood/ do
           {
             :tense => %w(present)
           }
         end
         all_vectors :end_with do
           {
             :number => %w(singular plural),
             :person => %w(first second third)
           }
         end
         exception :remove, :passive_voice_imperative_mood_present_tense
       end
     end
  end

  def test_basics
    v = Lingustics::Verbs::Verbvector::VerbvectorGenerator.new do
    end
  end

  def test_latin
   tense_list = Array.new(File.open(File.join(File.dirname(__FILE__), *%w[fixtures tense_list])).read.split /\s/)
   tense_list.sort!

   assert_equal tense_list, @vv.tense_list
   assert_equal 2,          @vv.match_vector_upto_aspect("voice").length
   assert_equal 5,          @vv.match_vector_upto_aspect("mood").length
   assert_equal 21,         @vv.match_vector_upto_aspect("tense").length
  end
  
  def test_extension
    m = @vv.create_module
    k = Class.new 
    k.class_eval do
      include m 
    end
    
    the_test = k.new
    the_test.razzle
         
  end
end