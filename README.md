# ruby-xcdm

This is a tool for generating the same xcdatamodeld files that Xcode
does when designing a datamodel for Core Data.  It is written in pure
ruby, but it will be of particular interest to RubyMotion developers.
It offers the essential features that Xcode does, plus a text-based
workflow and some niceties, like automatic inverse relationships.

[![Dependency Status](https://gemnasium.com/infinitered/ruby-xcdm.png)](https://gemnasium.com/infinitered/ruby-xcdm)
[![Build Status](https://travis-ci.org/infinitered/ruby-xcdm.png?branch=master)](https://travis-ci.org/infinitered/ruby-xcdm)
[![Gem Version](https://badge.fury.io/rb/ruby-xcdm.png)](http://badge.fury.io/rb/ruby-xcdm)

ruby-xcdm is maintained by [Infinite Red](http://infinite.red), a web and mobile development company based in Portland, OR and San Francisco, CA.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'ruby-xcdm'
```

And then execute:

```
  $ bundle
```

Or install it yourself as:

```
  $ gem install ruby-xcdm
```

## Usage (RubyMotion)

1. Make a directory called "schemas" inside your RubyMotion project
2. Create one schema version per file within the directory
3. To build the schema, run `rake schema:build`

If you want to build the schema every time you run the simulator, add
this to your Rakefile:

```ruby
task :"build:simulator" => :"schema:build"
```

You can override the name of the datamodel file, if you need to, using a config
variable:

```ruby
  app.xcdm.name = "custom"
```

## Usage (Plain Ruby)

1. Make a directory to hold your schemas (a.k.a. data model in XCode parlance)
2. Create one schema version per file within the directory
3. Run the command to generate a datamodel:

```
  xcdm MyApplicationName ./schema ./resources
```


## Schema File Format

Here's a sample schema file:

```ruby
  schema "001" do

    entity "Article" do

      string    :body,        optional: false
      integer32 :length
      boolean   :published,   default: false
      datetime  :publishedAt
      string    :title,       optional: false

      belongs_to :author
    end

    entity "Author" do
      float :fee
      string :name, optional: false
      has_many :articles
    end

  end
```

All the built-in data types are supported:

* integer16
* integer32
* integer64
* decimal (See note below)
* double
* float
* string
* boolean
* datetime
* binary
* transformable

NSDecimal is not well-supported in RubyMotion as of this writing.  They are converted to floats and lose precision.  HipByte is aware of the issue and intends to fix it, but until they do, you will need to use something else for storing currency.  For an example, see [here](https://github.com/skandragon/stringify_float).

Inverse relationships are generated automatically.
If the inverse relationship cannot be derived
from the association name, you can use the ```:inverse``` option:

```ruby
  entity "Game" do
    belongs_to :away_team, inverse: "Team.away_games"
    belongs_to :home_team, inverse: "Team.home_games"
  end

  entity "Team" do
    has_many :away_games, inverse: "Game.away_team"
    has_many :home_games, inverse: "Game.home_team"
  end
```

Many-to-many relationships are supported via the ```:plural_inverse``` option:

```ruby
  entity "Person" do
    has_many :threads, plural_inverse: true
  end

  entity "Thread" do
    has_many :people, plural_inverse: true
  end
```

In this mode, Core Data will automatically create a relation table behind the
scenes.  If you want more control, you can make the intermediate table yourself:

```ruby
  entity "Person" do
    has_many :postings
  end

  entity "Thread" do
    has_many :postings
  end

  entity "Posting" do
    belongs_to :person
    belongs_to :thread

    datetime :joined_at
  end
```

You can also have symmetric one-to-one relationships via has_one:

```ruby
  entity "Person" do
    has_one :ego
  end

  entity "Ego" do
    has_one :person
  end
```

Deletion rules can be easily set on relationships and the default rule is "Nullify":

```ruby
  entity "Discussion" do
    has_many :messages, deletionRule: "Cascade"
  end

  entity "Message" do
    belongs_to :discusion
  end

  # Example:
  # Discussion.first.messages.count => 10
  # Messages.count => 10
  # Discussion.first.destroy
  # cdq.save
  # Messages.count => 0
```

Core Data has no equivalent of ```:through``` in ActiveRecord, so you'll
need to handle that relation yourself.  

If you need to set some of the more esoteric options on properties or
relationships, you can include the raw parameters from
NSEntityDescription and NSAttributeDescription, like renamingIdentifier
or defaultValueString.

Additionally, if you need to set some `userInfo` properties, you can do so by
adding `user_info` to either the entity, attribute or relationship:

 ```ruby
   entity "Person" do
     user_info key: 'value'
     string :body, user_info: { key: 'value'}
     has_one :friend, user_info: { key: 'value' }
   end
 ```

## Versioning

To create new versions, simply copy the old version, increase the
version string (the last one in sort order is always interpreted to be
the current version) and make your changes.  So long as they conform
to the [automatic versioning
rules](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html#//apple_ref/doc/uid/TP40004399-CH4-SW2),
everything should work seamlessly.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
