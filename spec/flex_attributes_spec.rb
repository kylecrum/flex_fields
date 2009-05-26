require File.dirname(__FILE__) + '/spec_helper'

def common_instance_method_specs
  
  it 'can set and return flex values' do
    @model.foo = "I am a string"
    @model.bar = 5
    @model.foo.should == "I am a string"
    @model.bar.should == 5
  end

  it 'will only Base64 Encode string values' do
    some_string = "some_string"
    @model.foo = some_string
    @model.bar = 6
    @model[:something][:foo].should == "#{FlexAttributes::InstanceMethods::BASE64_TOKEN}#{Base64.encode64(some_string)}"
    @model[:something][:bar].should == 6
  end

  it 'will convert values to the specified type' do
    @model.bar = "6"
    @model.bar.should == 6
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

describe "FlexAttributes" do
  
  it 'is a part of ActiveRecord::Base' do
    SomeModel.should respond_to(:flex_attributes)
  end
  
  describe 'being declared in the model' do
    
    it 'uses a default column called flex' do
      SomeModel.should_receive(:serialize).with(:flex, Hash)
      SomeModel.flex_attributes
      SomeModel.flex_attributes_column.should == :flex
    end
    
    it 'can override the default column' do
      SomeModel.should_receive(:serialize).with(:something, Hash)
      SomeModel.flex_attributes :column_name=>'something'
      SomeModel.flex_attributes_column.should == :something
    end
    
    it 'creates getters and setters for each attribute specified' do
      SomeModel.flex_attributes :foo=>String, :bar=>Date
      some_model = SomeModel.new
      some_model.should respond_to(:foo)
      some_model.should respond_to(:foo=)
      some_model.should respond_to(:bar)
      some_model.should respond_to(:bar=)
    end
    
    it 'should call before_update to initialize the column' do
      SomeModel.should_receive(:before_update).with(:init_flex_column)
      SomeModel.flex_attributes
    end
    
    it 'can initialize flex values via the constructor' do
      SomeModel.flex_attributes :foo=>String, :bar=>Integer
      model = SomeModel.new(:foo=>'foo',:bar=>1)
      model.foo.should == 'foo'
      model.bar.should == 1
    end
    
    it 'should inherit settings for subclasses' do
      SomeModel.flex_attributes :foo=>String, :column_name=>:something
      InheritedModel.flex_attributes :bar=>Integer
      InheritedModel.flex_attributes_column.should == :something
      InheritedModel.flex_attributes_config.should == {:foo=>String,:bar=>Integer}
      inherited = InheritedModel.new
      inherited.should respond_to(:foo)
      inherited.should respond_to(:bar)
    end
    
    it 'takes the colum name from the base class that calls flex_attributes' do
      SomeModel.flex_attributes :column_name=>:some_column
      InheritedModel.flex_attributes :column_name=>:differet_column
      InheritedModel.flex_attributes_column.should == :some_column
    end
    
  end
  
  describe 'conversions' do
    
    before do
      SomeModel.flex_attributes
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
      
      #this returns the current time...don't want it to fail intermittantly, so 
      #I just make sure that we are looking at today
      @model.send(:convert_to_type,'foo',Time).to_date.should == Date.today
    end
    
  end
  
  describe 'instance methods' do
    
    describe 'without dirty tracking' do
    
      before do
        SomeModel.flex_attributes :foo=>String, :bar=>Integer, :column_name=>:something
        @model = SomeModel.new
      end
      
      it 'has default dirty tracking set to false' do
        SomeModel.included_modules.include?(FlexAttributes::Dirty).should be_false
      end
      
      it 'should return the flex column' do
        @model.send(:flex_attribute_column).should == :something
      end
    
      common_instance_method_specs
    
    end
    
    describe 'with dirty tracking' do
      
      before do
        SomeModel.flex_attributes :column_name=>:something, :track_dirty=>true, :foo=>String, :bar=>Integer
        @model = SomeModel.new
      end
      
      it 'should include the Dirty module' do
        SomeModel.included_modules.include?(FlexAttributes::Dirty).should be_true
      end
      
      common_instance_method_specs
      
      #regression test
      it 'should still be able to track normal dirty attributes' do
        @model.should_not be_changed
        @model.name = "Kyle"
        @model.should be_changed
        @model.should be_name_changed
        @model.name_was.should be_nil
        @model.name_change.should == [nil,"Kyle"]
        @model.name = "Bessie"
        @model.name_change.should == [nil,"Bessie"]
        @model.changed.should == ['name']
        @model.changes.should == {'name'=>[nil,'Bessie']}
      end
      
      describe 'after changing flex attributes' do
        
        before do
          @model.should_not be_changed
          @model.foo = 'foo'
        end
      
        it 'changed? should be true after changing flex attribute' do
          @model.should be_changed
        end
        
        it 'should return the flex attribute as changed' do
          @model.changed.should == ['foo']
          @model.changes.should == {'foo'=>[nil,'foo']}
        end
        
        it 'should return the flex attribute as part of the changes' do
          @model.changes.should == {'foo'=>[nil,'foo']}
        end
        
        it 'should respond to #{attribute_name}_changed? properly' do
          @model.should be_foo_changed
          @model.should_not be_bar_changed
        end
        
        it 'should clear changes after save' do
          @model.changes.should_not be_empty
          @model.name = 'name' #make sure it clears normal changes as well
          @model.save
          @model.changes.should be_empty
        end
        
        it 'should clear changes after save!' do
          @model.changes.should_not be_empty
          @model.name = 'name' #make sure it clears normal changes as well
          @model.save!
          @model.changes.should be_empty
        end
        
        it 'should clear changes after reload' do
          @model.save!
          @model.foo = 'foo2'
          @model.name = 'name' #make sure it clears normal changes as well
          @model.changes.should_not be_empty
          @model.reload
          @model.changes.should be_empty
        end
        
        it 'should handle #{attribute_name}_was properly' do
          @model.save!
          @model.foo = "foo2"
          @model.foo_was.should == 'foo'
        end
        
        it 'should handle #{attribute_name}_change properly' do
          @model.save!
          @model.foo = "foo2"
          @model.foo_change.should == ['foo','foo2']
        end
        
        it 'should handle #{attribute_name}_will_change! properly' do
          @model.save!
          @model.foo_change.should be_nil
          @model.foo_will_change!
          @model.foo_change.should_not be_empty
        end
        
        it 'should handle multiple changes' do
          @model.changes.should_not be_empty
          @model.foo = nil
          @model.changes.should be_empty
        end
        
        it 'should only mark a change when comparing after conversion' do
          @model.bar = 1
          @model.save!
          @model.bar = '1'
          @model.changes.should be_empty
          @model.bar = '2'
          @model.changes.should_not be_empty
        end
        
      end
      
    end
    
  end
  
end