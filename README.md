# MakeItSo

![Make It So](http://images.simplysyndicated.com/wp-content/uploads/2014/07/make-it-so-captain.jpg)

Make It So is a command line utility that makes it easy to create starting points
for all apps Ruby.

## Installation

Install it yourself as:

    $ gem install make_it_so

## Usage

Make It So has multiple options to help you get started.  You can get up and running with Rails, Sinatra, or Gosu without configuration issues.  If you would like to see a list of options:

```no-highlight
make_it_so
```

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

By default, the generator will create a Rails app with the following options activated:

- RSpec
- Devise
- Postgres
- Foundation
- React
- Karma

To take advantage of view-specific javascript, inject a script tag at the end of the body tag. Javascript should always be the last thing loaded on the page. In view logic you can do the following:

```erb
<%= content_for :extra_footer do %>
<script type="text/javascript">
var widget = new Something.Widget('foo');
</script>
<% end %>
```

There is experimental support for a `--jest` flag that will use Jest for client side testing instead of karma/jasmine.

### Sinatra

In the terminal, run:

```no-highlight
make_it_so sinatra <app_name>
```

By default, the generator will create a sinatra root complete with an RSpec configuration.

### Gosu

In the terminal, run:
```no-highlight
make_it_so gosu <app_name>
```

By default, the generator will create a gosu template complete with an RSpec configuration.

The tree structure looks like:  

```no-highlight  
GosuGame
├── Gemfile
├── README.md
├── game.rb
├── img
├── lib
│   ├── bounding_box.rb
│   └── keys.rb
└── spec
    └── spec_helper.rb
```  

To learn more about Gosu development [read through this tutorial](https://github.com/SpencerCDixon/Gosu-Tutorial)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/make_it_so/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
