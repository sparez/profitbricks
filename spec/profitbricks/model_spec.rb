require 'spec_helper'

module Profitbricks
  class ModelTest < Profitbricks::Model
  end

  class ModelHasManyTest < Profitbricks::Model
   has_many :model_tests
  end

  class ModelBelongsToTest < Profitbricks::Model
   belongs_to :model_has_many_test
  end
end

describe Profitbricks::Model do
  it "should define an attribute correclty" do
    mt = Profitbricks::ModelTest.new({:name => 'Test'})
    mt.name.should == 'Test'
  end

  it "should truncate redundant attribute name" do
    mt = Profitbricks::ModelTest.new({:model_test_name => 'Test'})
    mt.name.should == 'Test'
  end

  it "should create a has_many association correclty" do
    mt = Profitbricks::ModelHasManyTest.new( :model_tests => {:name => 'One'} )
    mt.model_tests.count.should == 1
    mt.model_tests.first.name.should == 'One'
  end

  it "should create a has_many association with two entries correclty" do
    mt = Profitbricks::ModelHasManyTest.new( :model_tests => [{:name => 'One'}, {:name => 'Two'}] )
    mt.model_tests.count.should == 2
    mt.model_tests.first.name.should == 'One'
    mt.model_tests.last.name.should == 'Two'
  end

  it "should create a belongs_to association correclty" do
    mt = Profitbricks::ModelBelongsToTest.new( :model_has_many_test => {:name => 'One'} )
    mt.model_has_many_test.class.should == Profitbricks::ModelHasManyTest
    mt.model_has_many_test.name.should == 'One'
  end
  
  it "should raise an LoadError exception" do
    lambda {
      module Profitbricks
        class Profitbricks::InvalidAssociation < Profitbricks::Model
          belongs_to :non_existant
        end
      end
    }.should raise_error(LoadError)
  end
end