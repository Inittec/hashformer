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
```
hash = { name: "Barrack", surname: "Obama", street: "1600 Pennsylvania Avenue", town: "Washington", postal_code: "20500", country: "United States" }
```

You want to rename keys with this rules:
* not `:name` but `:first_name`,
* `:last_name` instead of `:surname`,
* `:city` rather than `:town`
* `:postal_code` should be substituted by `:zip_code`,
* the rest is OK.
 
So, create mappings:
```
mappings = { name: :first_name, surname: :last_name, town: :city, postal_code: :zip_code }
```

Then, instantiate transformer with created mappings:
```
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
```
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
Nearly, but that's not it. If you want to deep transform, you must call `deep_value_action!` first, which will tell the transformer to analyse values. Then it will transform nested hashes and hashes hiding in arrays. See below:
```ruby
t.deep_value_action!
t.transform(hash)

# result
=> {:first_name=>"Barrack", :last_name=>"Obama", :address=>{:street=>"1600 Pennsylvania Avenue", :city=>"Washington", :zip_code=>"20500", :country=>"United States"}} 
```
Much better. Yo can also instantiate "deep transformers" by passing `:deep` symbol to the constructor:
```
t = Hash::Transformer.new(mappings, :deep)
```
### 2. Custom mapping actions
(As for now it doesn't work properly with nested hashes.)

Transformer has two principal attributes: `key_action` and `value action`. As you already know, by default it renames keys with mappings and does nothing with value. However, you can change this bahavior. Let's say we want to use only lowercase letters in values. What to do?
```ruby
# change value action
t.value_action = proc { |_k, v| v.respond_to?(:downcase) ? v.downcase : v }
t.transform(hash)

# result
=> {:first_name=>"barrack", :last_name=>"obama", :address=>{:street=>"1600 Pennsylvania Avenue", :town=>"Washington", :postal_code=>"20500", :country=>"United States"}}
```