# Prolog::Services::ReplaceContent

This Gem was extracted from an internally-developed application, which should somewhat explain the namespacing.

The Gem provides an (extremely) simple API for replacing a substring of "existing" HTML content, specified by zero-based endpoint indexes, with valid Markdown content, which may be partly or completely comprised of embedded HTML. Detailed API usage is documented below.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prolog-services-replace_content'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install prolog-services-replace_content
```

## Usage

```ruby
require 'prolog/services/replace_centent'

content = '<p>This is a <em>simple</em> test.</p>'
endpoint_begin = content.index ' <em>'
endpoint_end = content.index ' test.'

# ...

endpoints = (endpoint_begin..endpoint_end)
converter = Prolog::Services::ReplaceContent.new(content: content,
                                                 endpoints: endpoints,
                                                 replacement: 'basic' )

# Would replacing the specified range with the specified content result in valid
# and well-formed HTML?
converter.valid? # => true

# Replace content without using any surrounding markers
converter.convert # => true
converter.converted_content # => '<p>Tis is a basic test.</p>'

converter.markers = :a
converter.convert # need to repeat this after changing markers
converter.converted_content
# => '<p>This is a <a id="selection-begin"></a>basic<a id="selection-end"></a> test.</p>'
converter.errors.empty? # => true
converter.valid? # => true

# The same setup, only using Markdown input instead of HTML

content = 'This is a *simple* test.'
endpoint_begin = content.index '*simple*'
endpoint_end = content.index ' test.' # same as earlier
endpoints = (endpoint_begin..endpoint_end)
converter = Prolog::Services::ReplaceContent.new(content: content,
                                                 endpoints: endpoints,
                                                 replacement: 'basic' )

converter.convert # => true
converter.converted_content # => '<p>Tis is a basic test.</p>'


# Conversion inserting marker tag pairs (tag symbol required; text optional)

converter.markers = :span, 'testing-again'
converter.convert
converter.converted_content
# => '<p>This is a <span id="testing-again-begin"></span>basic<span id="testing-again-end"></span> test.</p>'

# Error conditions
#   Error Condition #1: Bad endpoints

content = '<p>This is a <em>simple</em> test.</p>'
endpoints = (15..28)
converter = Prolog::Services::ReplaceContent.new(content: content,
                                                 endpoints: endpoints,
                                                 replacement: 'basic' )
# with these params, `#converted_content` would return something like
#    '<p>This is a <e<a id="foo"></a>m>simple</em><a id="foo-end"></a> test.</p>'
# if we let it. Nope; no joy.

converter.valid? # <= false
converter.errors # <= { endpoints: ['force invalid HTML'] }
converter.convert # <= false
converter.converted_content # <= :failed_conversion ### *NOT* a string!

#   Error Condition #2: Bad source content
converter.content = '<p>This is bad content.</div>'
converter.valid? # => false
converter.convert # => false
converter.errors # => { content => ['invalid HTML'] }
converter.converted_content # => :failed_conversion

#   Error Condition #3: Replacement forces bad HTML
converter.content = '<p>This is <em>simple</em> content.</p>'
converter.replacement = 'bad '
converter.endpoints = (11..14)
# would convert to '<p>This is bad>simple</em> content.</p>'
converter.valid? # <= false
converter.errors # => { replacement: ['invalidates HTML'] }
converter.convert # => false
converter.converted_content # <= :failed_conversion

#   Error Condition #4: Attributes changed but `#convert` not called
converter = Prolog::Services::ReplaceContent.new(content: content,
                                                 endpoints: endpoints,
                                                 replacement: 'basic' )

converter.replacement = 'simplistic'
converter.valid? # => false
converter.errors # => { conversion: ['not called'] }
```



## API Reference

### Initialisation

#### `#initialize(**params = {})`

Creates an instance of the converter class, populating the `#content`, `#endpoints`, and `#replacement` attributes of the instance based on the specified values. Any of these may be omitted, which has the effect of using default values of `''`, `(-1..-1)`, and `''`, respectively.

### Attribute getters and setters

#### `#content`

The string specified as *source content* for the conversion, as either HTML or Markdown depending on which was originally used to specify the content (either from the initialiser or the `#content=` method).

#### `#content=(str)`

Specifies *source content*, either as HTML or Markdown, that will be used for the conversion in `#convert`. Specifying a new value using this method, and then calling `#converted_content` without having previously called `#convert`, will trigger an error condition (see `#convert` and/or `#errors` for details).

#### `#endpoints`

Returns the endpoints specified for the range within the `#content` which is to be replaced with the `#replacement_content`. This is a range of integers that follow Ruby conventions for string indexing (zero is the start of the string; `-1` is the last character in the string, `-2` is the second-to-last, etc). If not set by either `#initialize` or `#endpoints=`, defaults to `(-1..-1)`, which is rarely what is desired.

#### `#endpoints=(range)`

Assigns the endpoints of the range within the source `#content` which is to be replaced by the replacement content. Can be either an integer (specifying the ending endpoint, where the starting endpoint is set to zero, the beginning of the string) or a range of non-negative integers. If the specified value is invalid (either because it is not a valid range of non-negative integers or because the ending endpoint exceeds the length of the `#content` when `#convert` is called), will default to `(-1..-1)`.

#### `#replacement`

Returns the content string specified to replace the existing content within the endpoints, specified by either `#initialize` or `#replacement=`. This will be either HTML or Markdown, as specified to either of those two methods. (Using its HTML-converted value in the `#convert` method will not affect the attribute's value if it was assigned as Markdown.)

#### `#replacement=(str)`

Specifies content, either as Markdown or as HTML, whose HTML equivalent will be used to replace an existing range of content by a successful call to `#convert`. Assigning to this, or any of the other attributes, will trigger an error condition (see `#convert` and/or `#errors` for details).

The default value is the empty string.

### Action methods

#### `#convert`

Inserts marker tag pairs, if specified (see `#markers`), in the source content at the specified end­points, converting from Markdown to HTML, and then replacing the content between the marker tag pairs with the `#replacement_content`, then ensures that the resulting HTML is valid and well-formed. If no `#markers` were specified, removes them from the resulting HTML before assigning it to the `converted_content` attribute.

If the conversion was successful in all respects, returns `true`; else returns `false` and sets internal `errors` describing the failure which aborted the conversion.

### Query methods

#### `#converted_content`

Returns the product of the `#convert` method if that was successful, or `:failed_conversion` if it was not. Will also return `:failed_conversion` if not all prerequisite attributes (for content, endpoints, and replacement content) were set before calling `#convert`, or if any of these attributes were set but `#convert` was not called before calling `#converted_content`.

#### `#errors`

Returns a Hash-like object whose keys are attribute symbols (`:content`, `:endpoints`, `:replacement`), or the additional key `:conversion`, and whose values are an Array of simple strings identifying an error condition.

If the instance is valid, and no error condition has yet been triggered, then this method will return an empty Hash-like instance.

**Important Note:** Even though only one possible value for each key has yet been identified, that may change in future; with that in mind, the value associated with each key will always be an Array.

The keys and values for the Hash are enumerated below:

| Key            | Value                    |
| -------------- | ------------------------ |
| `:conversion`  | `['not called']`         |
| `:content`     | `['invalid HTML']`       |
| `:endpoints`   | `['force invalid HTML']` |
| `:replacement` | `['invalidates HTML']`   |



#### `#valid?`

Returns `true` if no attributes have been modified since a successful call to `#convert`. If no call to `#convert` has yet been made, regardless of attribute state, returns `false`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. *If you are a maintainer with write access to this repository,* to release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org). *Non-maintainers must not run this command*, and attempting to do so will fail.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TheProlog/prolog-services-markdown_to_html. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
