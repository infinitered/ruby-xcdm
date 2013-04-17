# ruby-xcdm

This is a tool for generating the same xcdatamodeld files that XCode does when designing a datamodel for Core Data. 
It is written in pure ruby, but it will be of particular interest to RubyMotion developers.  

## Installation

Add this line to your application's Gemfile:

    gem 'ruby-xcdm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-xcdm

## Usage

1. Make a directory to hold your schemas (a.k.a. data model in XCode parlance)
2. Create one schema version per file within the directory
3. Run the command to generate a datamodel:

  xcdm MyApplicationName schemadir datamodeldestdir


## Schema File Format

Here's a sample schema file:

  schema "0.0.1" do

    entity "Article" do

      string    :body,        optional: false
      integer32 :length
      boolean   :published,   default: false
      datetime  :publishedAt, default: false
      string    :title,       optional: false

      has_one   :author
    end

    entity "Author" do
      float :fee
      string :name, optional: false
      has_many :articles 
    end

  end

It's pretty self-explanatory. All the built-in data types are supported, and inverse relationships are 
generated automatically.  If you need to set some of the more esoteric options on properties or
relationships, you can include the raw parameters, like renamingIdentifier or defaultValueString.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
