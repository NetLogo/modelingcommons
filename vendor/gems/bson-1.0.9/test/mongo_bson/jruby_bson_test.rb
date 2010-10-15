# encoding:utf-8
require 'test/test_helper'
require 'complex'
require 'bigdecimal'
require 'rational'
require 'benchmark'

MEDIUM = {
  'integer' => 5,
  'number' => 5.05,
  'boolean' => false,
  'array' => ['test', 'benchmark']
}


LARGE = {
  'base_url' => 'http://www.example.com/test-me',
  'total_word_count' => 6743,
  'access_time' => Time.now,
  'meta_tags' => {
    'description' => 'i am a long description string',
    'author' => 'Holly Man',
    'dynamically_created_meta_tag' => 'who know\n what'
  },
  'page_structure' => {
    'counted_tags' => 3450,
    'no_of_js_attached' => 10,
    'no_of_images' => 6
  },
  'harvested_words' => ['10gen','web','open','source','application','paas',
                        'platform-as-a-service','technology','helps',
                        'developers','focus','building','mongodb','mongo'] * 20
}



begin
  require 'active_support/core_ext'
  require 'active_support/hash_with_indifferent_access'
  Time.zone = "Pacific Time (US & Canada)"
  Zone = Time.zone.now
rescue LoadError
  warn 'Could not test BSON with HashWithIndifferentAccess.'
  module ActiveSupport
    class TimeWithZone
    end
  end
  Zone = ActiveSupport::TimeWithZone.new
end

class BSONTest < Test::Unit::TestCase
  include BSON
  
  def setup
    @coder = BSON::BSON_CODER
  end

  def assert_doc_pass(doc)
    bson = @coder.serialize(doc)
    assert_equal doc, @coder.deserialize(bson)
  end

  def test_string
    assert_doc_pass({'doc' => 'hello, world'})
  end

  def test_nested_string
    assert_doc_pass({'doc' => {'text' => 'hello, world'}})
  end

  def test_array
    assert_doc_pass({'doc' => ['1', 2, 3]})
  end

  def test_object
    assert_doc_pass({'doc' => {'age' => 42, 'name' => 'Spongebob', 'shoe_size' => 9.5}})
  end

  def test_boolean
    doc = {'foo' => true}
    bson = @coder.serialize(doc)
    assert_equal doc, @coder.deserialize(bson)
  end

  def test_nil
    assert_doc_pass({'foo' => nil})
  end

  def test_time
    assert_doc_pass({'foo' => Time.now})
  end

  def test_regex
    assert_doc_pass({'foo' => /^a/im})
  end

  def test_symbol
    assert_doc_pass({'foo' => :bar})
  end

  def test_valid_utf8_string
    doc = {'doc' => 'aé'}
    bson = bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_valid_utf8_key
    doc = {'aé' => 'hello'}
    bson = bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_number
    doc = {'doc' => 41.99}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_int
    doc = {'doc' => 42}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)

    doc = {"doc" => -5600}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)

    doc = {"doc" => 2147483647}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)

    doc = {"doc" => -2147483648}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_ordered_hash
    doc = BSON::OrderedHash.new
    doc["b"] = 1
    doc["a"] = 2
    doc["c"] = 3
    doc["d"] = 4
    bson = BSON::BSON_CODER.serialize(doc)
    p bson
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_object
    doc = {'doc' => {'age' => 42, 'name' => 'Spongebob', 'shoe_size' => 9.5}}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_oid
    doc = {'doc' => ObjectID.new}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_array
    doc = {'doc' => [1, 2, 'a', 'b']}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_regex
    doc = {'doc' => /foobar/i}
    bson = BSON::BSON_CODER.serialize(doc)
    doc2 = BSON::BSON_CODER.deserialize(bson)
    assert_equal doc, doc2

    r = doc2['doc']
    assert_kind_of Regexp, r

    doc = {'doc' => r}
    bson_doc = BSON::BSON_CODER.serialize(doc)
    doc2 = nil
    doc2 = BSON::BSON_CODER.deserialize(bson_doc)
    assert_equal doc, doc2
  end

  def test_boolean
    doc = {'doc' => true}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_date
    doc = {'date' => Time.now}
    bson = BSON::BSON_CODER.serialize(doc)
    doc2 = BSON::BSON_CODER.deserialize(bson)
    # Mongo only stores up to the millisecond
    assert_in_delta doc['date'], doc2['date'], 0.001
  end

  def test_date_returns_as_utc
    doc = {'date' => Time.now}
    bson = BSON::BSON_CODER.serialize(doc)
    doc2 = BSON::BSON_CODER.deserialize(bson)
    assert doc2['date'].utc?
  end

  def test_dbref
    oid = ObjectID.new
    doc = {}
    doc['dbref'] = DBRef.new('namespace', oid)
    bson = BSON::BSON_CODER.serialize(doc)
    doc2 = BSON::BSON_CODER.deserialize(bson)
    assert_equal 'namespace', doc2['dbref'].namespace
    assert_equal oid, doc2['dbref'].object_id
  end

  def test_symbol
    doc = {'sym' => :foo}
    bson = BSON::BSON_CODER.serialize(doc)
    doc2 = BSON::BSON_CODER.deserialize(bson)
    assert_equal :foo, doc2['sym']
  end

#  def test_regex_extended
#    assert_doc_pass({'foo' => /^a/x})
#  end
#
   def test_object_id
     assert_doc_pass({'_id' => BSON::ObjectID.new})
   end
end
