![Hashformer Logo](https://raw.githubusercontent.com/Inittec/hashformer/master/hashformer.png)

# Hashformer (α-version)
Hashformer is a package including simple hash transformer class (Hash::Transformer). It makes easier performing on hashes such operations as:
  * renaming keys with mappings,
  * custom mapping actions on keys and/or values.

## Installation

Add this line to your application's Gemfile:

    gem 'hashformer', git: 'https://github.com/Inittec/hashformer.git'

And then execute:

    $ bundle

## Usage
Here are some examples of Hashformer usage.

### 1. Renaming keys with mappings
#### Simple Sample
Lets assume that you have following hash in your application:
```ruby
hash = { name: "Barrack", surname: "Obama", street: "1600 Pennsylvania Avenue", town: "Washington", postal_code: "20500", country: "United States" }
```

You want to rename keys with this rules:
* not `:name` but `:first_name`,
* `:last_name` instead of `:surname`,
* `:city` rather than `:town`
* `:postal_code` should be substituted by `:zip_code`,
* the rest is OK.
 
So, create mappings:
```ruby
mappings = { name: :first_name, surname: :last_name, town: :city, postal_code: :zip_code }
```

Then, instantiate transformer with created mappings:
```ruby
t = Hash::Transformer.new(mappings)
```

Mapping keys is a default action, so all you need is just to use `transform` method with your hash as input:
```ruby
t.transform(hash)

# result
=> {:first_name=>"Barrack", :last_name=>"Obama", :street=>"1600 Pennsylvania Avenue", :city=>"Washington", :zip_code=>"20500", :country=>"United States"}
```
#### Nested hashes
That was easy, what about nested hashes? Let's try with this one:
```ruby
hash = { name: "Barrack", surname: "Obama", address_data: { street: "1600 Pennsylvania Avenue", town: "Washington", postal_code: "20500", country: "United States" } }
```
Now, your quest is to rename keys as previously, plus: `:addres_data` should be changed to `address`. 3 - 2 - 1...
```ruby
# add rule to mappings
t.mappings.merge!(address_data: :address)

# go!
t.transform(hash)

# result
=> {:first_name=>"Barrack", :last_name=>"Obama", :address=>{:street=>"1600 Pennsylvania Avenue", :town=>"Washington", :postal_code=>"20500", :country=>"United States"}}
```
Nearly, but that's not it. If you want to enable deep transforming, you must call `deep` method first. Then it will transform nested hashes and hashes hiding in arrays. See below:
```ruby
t.deep.transform(hash)

# result
=> {:first_name=>"Barrack", :last_name=>"Obama", :address=>{:street=>"1600 Pennsylvania Avenue", :city=>"Washington", :zip_code=>"20500", :country=>"United States"}} 
```
Much better. You can disable deep transforming with `shallow` method. If you want to check your transformer settings, call `deep?`.
```ruby
# change to shallow transforming
t.shallow
t.deep?
# => false

# change to deep transforming
t.deep
t.deep?
# => true
```
### 2. Custom mapping actions
Transformer has two principal attributes: `key_action` and `value action`. As you already know, by default it renames keys with mappings and does nothing with value. However, you can change this behavior. Let's say we want to use only lowercase letters in values. What to do?
```ruby
# change value action
t.value_action = proc { |v| v.respond_to?(:downcase) ? v.downcase : v }

# shallow transform
t.transform(hash)

# result
=> {:first_name=>"barrack", :last_name=>"obama", :address=>{:street=>"1600 Pennsylvania Avenue", :town=>"Washington", :postal_code=>"20500", :country=>"United States"}}

# go deeper
t.deep.transform(hash)

# result
=> {:first_name=>"barrack", :last_name=>"obama", :address=>{:street=>"1600 pennsylvania avenue", :city=>"washington", :zip_code=>"20500", :country=>"united states"}}
```
By analogy, you can change key action:
```ruby
# change key action
t.key_action = proc { |k| k.upcase }

# shallow transform
t.shallow.transform(hash)

# result
=> {:NAME=>"barrack", :SURNAME=>"obama", :ADDRESS_DATA=>{:street=>"1600 Pennsylvania Avenue", :town=>"Washington", :postal_code=>"20500", :country=>"United States"}}

# deep transform
t.deep.transform(hash)

# result
=> {:NAME=>"barrack", :SURNAME=>"obama", :ADDRESS_DATA=>{:STREET=>"1600 pennsylvania avenue", :TOWN=>"washington", :POSTAL_CODE=>"20500", :COUNTRY=>"united states"}} 
```
As for now, if you modified key action, mappings are being ignored.