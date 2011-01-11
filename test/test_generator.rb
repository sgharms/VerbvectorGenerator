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
         cluster_on :tense, "as method", :tense_list
       end
     end
  end

  def test_basics
    v = Lingustics::Verbs::Verbvector::VerbvectorGenerator.new do
    end
    
    assert_not_nil(v)
  end

  def test_vector_matcher
   assert_equal 2,          @vv.match_vector_upto_aspect("voice").length
   assert_equal 5,          @vv.match_vector_upto_aspect("mood").length
   assert_equal 21,         @vv.match_vector_upto_aspect("tense").length
  end
  
  def test_tense_resolution
    tense_list = Array.new(File.open(File.join(File.dirname(__FILE__), *%w[fixtures tense_list])).read.split /\s/)
    tense_list.sort!

    tc = Class.new
    tc.extend @vv.create_module        

    assert_equal tense_list, tc.tense_list
  end

  def test_clustering_with_regex
    t = 
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
         cluster_on /active_voice.*third/, "as method", :active_thirds
       end
     end
     tc = Class.new
     tc.extend t.create_module
     assert_respond_to(tc, :active_thirds)
     assert_equal(22, tc.active_thirds.length)
  end
  
  def test_extension
    tc = Class.new
    tc.extend @vv.create_module        
    assert_respond_to(tc, :active_voice_indicative_mood_imperfect_tense_singular_number_third_person)
  end
  
  def test_clustering
    assert_respond_to(@vv, :vectors_that)
    assert_respond_to(@vv, :cluster_on)
  end
end