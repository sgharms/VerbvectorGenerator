require "test/unit"

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require "verbvector"

class TestVerbVector  < Test::Unit::TestCase
  def test_basics
    v = Lingustics::Verbs::Verbvector::VerbvectorGenerator.new do
      puts "i am larry"
    end
  end
  def test_latin
    Lingustics::Verbs::Verbvector::VerbvectorGenerator.new do
      # language :Latin has do
      end
    end
  end
end