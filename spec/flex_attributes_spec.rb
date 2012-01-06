require 'spec_helper'

describe "FlexAttributes" do
  
  it 'is a part of ActiveRecord::Base' do
    SomeModel.should respond_to(:flex_fields)
  end
  
  after do
    reset_classes
  end
  
  describe 'being declared in the model' do
    
    it 'uses a default column called flex' do
      SomeModel.should_receive(:serialize).with(:flex, Hash)
      SomeModel.flex_fields
      SomeModel.flex_fields_column.should == :flex
    end
    
    it 'can override the default column' do
      SomeModel.should_receive(:serialize).with(:something, Hash)
      SomeModel.flex_fields :column_name=>'something'
      SomeModel.flex_fields_column.should == :something
    end
    
    it 'creates getters and setters for each attribute specified' do
      SomeModel.flex_fields :foo=>String, :bar=>Date
      some_model = SomeModel.new
      some_model.should respond_to(:foo)
      some_model.should respond_to(:foo=)
      some_model.should respond_to(:bar)
      some_model.should respond_to(:bar=)
    end
    
    it 'can initialize flex values via the constructor' do
      SomeModel.flex_fields :foo=>String, :bar=>Integer
      model = SomeModel.new(:foo=>'foo',:bar=>1)
      model.foo.should == 'foo'
      model.bar.should == 1
    end
    
    it 'should inherit settings for subclasses' do
      SomeModel.flex_fields :foo=>String, :column_name=>:something
      InheritedModel.flex_fields :bar=>Integer
      InheritedModel.flex_fields_column.should == :something
      InheritedModel.flex_fields_config.should == {:foo=>String,:bar=>Integer}
      inherited = InheritedModel.new
      inherited.should respond_to(:foo)
      inherited.should respond_to(:bar)
    end
    
    it 'takes the colum name from the base class that calls flex_fields' do
      SomeModel.flex_fields :column_name=>:some_column
      InheritedModel.flex_fields :column_name=>:differet_column
      InheritedModel.flex_fields_column.should == :some_column
    end
    
  end
  
  describe 'conversions' do
    
    before do
      SomeModel.flex_fields
      @model = SomeModel.new
    end
    
    it 'can convert arrays' do
      @model.send(:convert_to_type,[1,2,3],Array).should == [1,2,3]
      @model.send(:convert_to_type,1,Array).should == [1]
    end
    
    it 'can convert dates' do
      date_string = '1979-12-05'
      date = Date.parse(date_string)
      @model.send(:convert_to_type,date_string,Date).should == date
      @model.send(:convert_to_type,date,Date).should == date
      @model.send(:convert_to_type,'foo',Date).should be_nil
    end
    
    it 'can convert date times' do
      date_time_string = '1979-12-05T08:30:45Z'
      date_time = DateTime.parse(date_time_string)
      @model.send(:convert_to_type,date_time_string,DateTime).should == date_time
      @model.send(:convert_to_type,date_time,DateTime).should == date_time
      @model.send(:convert_to_type,'foo',DateTime).should be_nil
    end
    
    it 'can convert floats' do
      @model.send(:convert_to_type,3.14159,Float).should == 3.14159
      @model.send(:convert_to_type,'3.14159',Float).should == 3.14159
    end
    
    it 'can convert hashes' do
      @model.send(:convert_to_type,{:foo=>'bar'},Hash).should == {:foo=>'bar'}
      @model.send(:convert_to_type,'foobar',Hash).should be_nil
    end
    
    it 'can convert integers' do
      @model.send(:convert_to_type,1,Integer).should == 1
      @model.send(:convert_to_type,'1',Integer).should == 1
    end
    
    it 'can convert strings' do
      @model.send(:convert_to_type,"string",String).should == "string"
      @model.send(:convert_to_type,3.14159,String).should == "3.14159"
    end
    
    it 'can convert times' do
      time_string = "16:30"
      time = Time.parse(time_string)
      @model.send(:convert_to_type,time_string,Time).should == time
      @model.send(:convert_to_type,time,Time).should == time
      @model.send(:convert_to_type,'foo',Time).should be_nil
    end
    
  end
  
  describe 'instance methods' do
    
    before do
      SomeModel.flex_fields :foo=>String, :bar=>Integer, :column_name=>:something
      @model = SomeModel.new
    end
    
    it 'should return the flex column' do
      @model.send(:flex_fields_column).should == :something
    end
    
    it 'should return the correct flex type for an attribute' do
      @model.send(:type_for_flex_field, :foo).should == String
    end
  
    it 'can set and return flex values' do
      @model.foo = "I am a string"
      @model.bar = 5
      @model.foo.should == "I am a string"
      @model.bar.should == 5
    end

    it 'will save values properly' do
      @model.bar = "6"
      @model.foo = "foo"
      @model.save!
      saved_model = SomeModel.find(@model.id)
      saved_model.bar.should == 6
      saved_model.foo.should == "foo"
    end
    
  end
  
end