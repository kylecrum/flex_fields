Flex Fields
===============

Flex Fields allows you to define an arbitrary amount of data to be stored in 
a serialized column.  Why?  Because sometimes you have data that just doesn't need
to be in its own column. 

## Installation ##

You should have a column in your database in order to store the serialized data.  Make the
column name "flex" for it to work out of the box. 

```
class AddFlexFieldsColumn < ActiveRecord::Migration
  def change
    add_column :some_table, :flex, :text
  end
end
```

  
## Examples ##

To activate, just need to declare flex_fields in your model.

```
	class MyModel < ActiveRecord::Base
		flex_fields :foo=>String, :bar=>Integer
	end
```		
		
This gives you two new flex fields: foo and bar

```
	my_model = MyModel.new(:foo=>'foo',:bar=>1)
	my_model.foo
		=> 'foo'
	my_model.bar
		=> 1
```
			
Flex Fields works nicely with inheritance and STI, too, so don't worry about that!

```
	class AnotherModel < MyModel
		flex_fields :more_stuff=>Array
	end
	
	another_model = AnotherModel.new
	another_model.foo
		=> nil
	another_model.more_stuff
		=> []
```
			
By default, the data is stored in a serialized Hash in a column called 'flex'
You can change this by passing in column_name.

```
	class MyModel < ActiveRecord::Base
		flex_fields :column_name=>:data, :foo=>String, :bar=>Integer
	end
```
		
Now, everything is stored in a serialized hash in the data column.

Just like in ActiveRecord, if you want to override the default getter and setter methods,
you can.  Instead of using write_attribute and read_attribute, use write_flex_field and
read_flex_field

```
	class MyModel < ActiveRecord::Base
	
		flex_fields :foo=>String, :bar=>Integer
		
		def foo
			logger.debug("I am accessing foo")
			read_flex_field(:foo)
		end
		
		def foo=(new_val)
			logger.debug("I am setting foo to a new value")
			write_flex_field(:foo,new_val)
		end
	
	end
```
	
## Conversions ##

Flex Attributes will convert the value to the class you specify in the declaration

```
	class MyModel < ActiveRecord::Base
		flex_fields :float_value=>Float, :integer_value=>Integer
	end
	
	model = MyModel.new
	model.float_value = '1'
	model.float_value
		=> 1.0
	model.integer_value = '1'
	model.integer_value
		=> 1
```			
Currently, Flex Fields supports these types of fields:

	Array
	Date
	DateTime
	Float
	Hash
	Integer
	String
	Time