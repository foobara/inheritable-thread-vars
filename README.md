# foobara-thread-parent gem

Thread variables are specific to their threads but perhaps you might find yourself
in a situation where you would like to set a thread variable to something that is also
accessible to any child threads created from that thread. Well, great news then...
this gem lets you do just that!

## Installation

Typical stuff: add `gem "foobara-thread-parent"` to your Gemfile or .gemspec file. Or even just
`gem install foobara-thread-parent` if just playing with it directly in scripts.

## Usage

```ruby
require "foobara/thread-parent"

Thread.inheritable_thread_local_var_set("some_var", "parent_value")
Thread.inheritable_thread_local_var_get("some_var") # "parent_value"

Thread.new do
  Thread.inheritable_thread_local_var_get("some_var") # "parent_value"
  Thread.inheritable_thread_local_var_set("some_var", "child_value")
  Thread.inheritable_thread_local_var_get("some_var") # "child_value"
end

Thread.inheritable_thread_local_var_get("some_var") # "parent_value"
```

## Contributing

Bug reports and pull requests are welcome on GitHub
at https://github.com/foobara/thread-parent

## License

This project is dual licensed under your choice of the Apache-2.0 license and the MIT license.
Please see LICENSE.txt for more info.
