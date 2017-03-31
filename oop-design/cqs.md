## Command-query separation

A method should either be a _command_ (which have side effect) or a _query_ (which return value) to the caller, but not both.

> Asking a question should not change the answer

_query_ methods should not alter or affect the system state and only return result. _command_ method should not return result or their result should not be used as input of other operations.

_command_ method examples:

```ruby
User.create
Worker.perform
```

_query_ method examples:

```ruby
File.exists?(path)
user = User.new; user.persisted?
```

Sometimes it's more convenient to have method that is combined both command and query. For example, the `pop()` method of a `stack`.
