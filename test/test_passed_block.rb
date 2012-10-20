require "test/unit"

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require "verbvector"

class TestProcBasedDefinition < Test::Unit::TestCase
  def setup
    @dsl_proc = Proc.new do
       language :Latin do
         all_vectors :start_with do
            {
             :voice =>  %w(active passive),
             :mood  =>  %w(indicative subjunctive imperative)
            }
         end
         vectors_that( /.*_indicative_mood/ ) do
           {
             :tense  => %w(present imperfect future
                           perfect pastperfect futureperfect)
           }
         end
         vectors_that( /.*_subjunctive_mood/ ) do
           {
             :tense => %w(present imperfect
                           perfect pastperfect)
           }
         end
         vectors_that( /.*_imperative_mood/ ) do
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
    @vv = Linguistics::Verbs::Verbvector::VerbvectorGenerator.new(&@dsl_proc)
  end

  def test_basics
    v = Linguistics::Verbs::Verbvector::VerbvectorGenerator.new do
    end

    assert_not_nil(v)
    assert_equal(:Latin, @vv.language)
  end

  def test_vector_matcher
   assert_equal 2,          @vv.match_vector_upto_aspect("voice").length
   assert_equal 5,          @vv.match_vector_upto_aspect("mood").length
   assert_equal 21,         @vv.match_vector_upto_aspect("tense").length
  end

  def test_extension
    tc = Class.new
    tc.extend @vv.method_extension_module
    assert_respond_to(tc, :latin_active_voice_indicative_mood_imperfect_tense_singular_number_third_person)
  end

  def test_clustering
    assert_respond_to(@vv, :vectors_that)
    assert_respond_to(@vv, :cluster_on)

    tc = Class.new
    tc.extend @vv.method_extension_module

    # Make sure that each cluster method is /not/ defined.  We want these to
    # be defined "for real," not as a proxy.

    cms=@vv.cluster_methods[:tense_list].call
    cms.each do |m|
      assert not(tc.respond_to? m.to_sym)
    end
  end

end
