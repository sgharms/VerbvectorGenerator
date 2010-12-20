require "test/unit"

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require "verbvector"

class TestVerbVector  < Test::Unit::TestCase
  def setup
    @tense_list = Array.new(File.open(File.join(File.dirname(__FILE__), *%w[fixtures tense_list])).read.split /\s/)
    @tense_list.sort!
  end
  def test_basics
    v = Lingustics::Verbs::Verbvector::VerbvectorGenerator.new do
    end
  end
  def test_latin
    vv = 
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
         all_vectors :end_with do
           {
             :number => %w(singular plural),
             :person => %w(first second third)
           }
         end
       end
     end
   assert_equal(@tense_list, vv.tense_list)
   assert_equal(2, vv.match_vector_upto_aspect("voice").length)

  end
end