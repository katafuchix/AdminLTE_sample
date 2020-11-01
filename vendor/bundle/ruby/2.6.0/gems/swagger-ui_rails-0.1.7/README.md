# Swagger::UiRails

A gem that lets you add [swagger-ui](https://github.com/wordnik/swagger-ui) easily to your rails application

## Installation

Add this line to your application's Gemfile:

    gem 'swagger-ui_rails'

## Usage

Add to your application.js

    //= swagger-ui

Add to your application.css

    *= swagger-ui

Then add to some api_docs/index.html

    = render 'swagger_ui/swagger_ui', discovery_url: 'root/to/swagger_doc.json'

or create your own html page according to [swagger-ui sample](https://github.com/wordnik/swagger-ui/blob/master/dist/index.html)

## Related projects

[Grape](https://github.com/intridea/grape)
[grape-swagger](https://github.com/tim-vandecasteele/grape-swagger)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
