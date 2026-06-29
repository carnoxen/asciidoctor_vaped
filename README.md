# AsciidoctorVaped

I vibed this project inspired by [Asciidoctor](https://asciidoctor.org). It has a long history,
but I can't read lots of if-else statements. So, I made this.
It is still in development. Be careful to use.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add asciidoctor_vaped
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install asciidoctor_vaped
```

## Usage

```sh
# just print a html file from adoc file.
asciidoctor_vaped demo.adoc

# this can accept a text.
asciidoctor_vaped -s 'hello *world*'

# or print something different like docbook.
asciidoctor_vaped demo.adoc demo.dkb
```

### Source highlighting and callouts

Highlight.js is used by default for HTML source blocks. Select an optional
server-side highlighter with the `syntax-highlighter` document attribute:

```adoc
:syntax-highlighter: rouge

[source,ruby]
----
puts "hello" # <1>
----
<1> Prints a greeting.
```

Install `rouge` for `:syntax-highlighter: rouge`, or `pygments.rb` for
`:syntax-highlighter: pygments`. These gems are loaded only when selected.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carnoxen/asciidoctor_vaped.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
