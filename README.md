# Prolog::Services::ReplaceContent

[ ![Codeship Status for TheProlog/prolog-services-replace_content](https://codeship.com/projects/de342330-da58-0133-0093-5a647b2fc712/status?branch=master)](https://codeship.com/projects/143778) [![Code Climate](https://codeclimate.com/github/TheProlog/prolog-services-replace_content/badges/gpa.svg)](https://codeclimate.com/github/TheProlog/prolog-services-replace_content) [![Test Coverage](https://codeclimate.com/github/TheProlog/prolog-services-replace_content/badges/coverage.svg)](https://codeclimate.com/github/TheProlog/prolog-services-replace_content/coverage) [![Issue Count](https://codeclimate.com/github/TheProlog/prolog-services-replace_content/badges/issue_count.svg)](https://codeclimate.com/github/TheProlog/prolog-services-replace_content)&nbsp;[![Dependency Status](https://gemnasium.com/TheProlog/prolog-services-replace_content.svg)](https://gemnasium.com/TheProlog/prolog-services-replace_content)


This Gem was extracted from an internally-developed application, which should somewhat explain the namespacing.

The Gem provides an (extremely) simple API for replacing a substring of "existing" HTML content, specified by zero-based endpoint indexes, with valid HTML content, which may be partly or completely comprised of embedded HTML. Detailed API usage is documented below.

**Important:** The initial release of this Gem *only* supports HTML for source and replacement content; no Markdown content is supported. This means that, for example,. specifying a simple string with­out tags as replacement content will attempt to replace the selected range with *just that text*; if that causes the resulting HTML to be invalid, it will be reported as an error.

A future release of this Gem is expected to support specification of source and/or replacement content in *either* HTML or Markdown (which, remember, is a proper superset of HTML). The tools presently available for supporting this, however, are presently stumped by several corner cases we have devised that are likely enough to occur "in the wild" to be of serious concern.

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

The HTML content specified as *source content* for the conversion, as specified either from the initialiser or the `#content=` method. Is guaranteed to return either an empty string or valid HTML.

#### `#content=(str)`

Specifies HTML *source content* that will be used for the conversion in `#convert`. Specifying a new value using this method, and then calling `#converted_content` without having previously called `#convert`, will trigger an error condition (see `#convert` and/or `#errors` for details).

#### `#endpoints`

Returns the endpoints specified for the range within the `#content` which is to be replaced with the `#replacement_content`. This is a range of integers that follow Ruby conventions for string indexing (zero is the start of the string; `-1` is the last character in the string, `-2` is the second-to-last, etc). If not set by either `#initialize` or `#endpoints=`, defaults to `(-1..-1)`, which is rarely what is desired.

#### `#endpoints=(range)`

Assigns the endpoints of the range within the source `#content` which is to be replaced by the re­placement content. Can be either an integer (specifying the ending endpoint, where the starting endpoint is set to zero, the beginning of the string) or a range of non-negative integers. If the speci­fied value is invalid (either because it is not a valid range of non-negative integers or because the ending endpoint exceeds the length of the `#content` when `#convert` is called), will default to `(-1..-1)` and cause an error to be reported (see `#errors`, below).

#### `#markers=`

Specifies the details of the marker tag pairs to be used to wrap the content within the endpoints. If not explicitly set, no such tag pairs will be used. May be set using a symbolic HTML tag name (e.g. `:span` for the HTML `<span>` tag pair) and, optionally, an "identifier" string.

Examples:

```ruby
# Setting the HTML tag used for the tag pairs to the `<a>` tag
# ...
converter.markers = :a
converter.convert
converter.converted_content
# => '<p>This is a <a id="selection-begin"></a>basic<a id="selection-end"></a> test.</p>'

# Setting the markers to the '<a>' tag and the identifier prefix to 'mambo-no-5'
converter.markers = :a, 'mambo-no-5'
converter.convert
converter.converted_content
# => '<p>This is a <a id="mambo-no-5-begin"></a>basic<a id="mambo-no-5-end"></a> test.</p>'

# Setting the HTML tag without setting the identifier resets the latter to 'selection'
converter.markers = :span
converter.convert
converter.converted_content
# => '<p>This is a <span id="selection-begin"></span>basic<span id="selection-end"></span> test.</p>'

```

**Note** that setting the markers, as with setting any of the other attributes, invalidates any previous conversion and requires the `#convert` method to be called again prior to calling `#converted_content`.

#### `#replacement`

Returns the content string specified to replace the existing content within the endpoints, specified by either `#initialize` or `#replacement=`. This is guaranteed to be either an empty string or a valid HTML string.

#### `#replacement=(str)`

Specifies content, as an HTML string, that will be used to replace an existing range of content by a successful call to `#convert`. Assigning to this, or any of the other attributes and then calling `#converted_content` without first calling `#convert` will report an error (see `#convert` and/or `#errors` for details).

If a string without HTML tags is specified, then it will be used literally; if replacing the content between the endpoints with that replacement string results in invalid HTML, then that also will cause an error to be reported.

The default value is the empty string.

### Action methods

#### `#convert`

Inserts marker tag pairs, if specified (see `#markers`), in the source content at the specified end­points, and then replaces the content corresponding to the original endpoints (whether or not bounded by marker tag pairs) with the `#replacement_content`, then ensures that the resulting HTML is valid and well-formed. If no `#markers` were specified, removes them from the resulting HTML before assigning it to the `converted_content` attribute.

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `rake install`. *If you are a maintainer with write access to this repository,* to release a new version, update the version number in `version.rb`, and then run `rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org). *Non-maintainers must not run this command*, and attempting to do so will fail.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TheProlog/prolog-services-markdown_to_html. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

