# MakeItSo

![Make It So](http://images.simplysyndicated.com/wp-content/uploads/2014/07/make-it-so-captain.jpg)

Make It So is a command line utility that makes it easy to create starting points
for all apps ruby. Right now, it only supports Rails, but support for Sinatra,
Gosu, and other paradigms are in progress.

## Installation

Add this line to your application's Gemfile:

Install it yourself as:

    $ gem install make_it_so

## Usage


### Rails

In the terminal, run:

```no-highlight
make_it_so rails <app_name>
```

Then run:

```ruby
rake db:create
rake db:migrate
```

## Extra Footer in Views

Inject javascript at the end of the body tag. Javascript should always be the last thing loaded on the page. In view logic you can do the following:

```erb
<%= content_for :extra_footer do %>
  <script type="text/javascript">
    var widget = new Something.Widget('foo');
  </script>
<% end %>
```

### Sinatra

In the terminal, run:

```no-highlight
make_it_so sinatra <app_name>
```

By default, the generator, will create a sinatra root complete with an RSpec configuration.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/make_it_so/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
