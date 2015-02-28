To be able to skip, delete or reset rails validation, first you have to know where rails stored those validations callbacks. The validation callback information is stored in these two accessor: `_validators` and `_validate_callbacks`. `_validators` contains only information used for reflection, but not the actual validator callbacks. Instead `_validate_callbacks` is used to stored validation callbacks.

The `_validate_callbacks` accessor is an instance of ActiveSupport::Callbacks::CallbackChain class. So to safely remove validation callbacks from class, you might use:

```ruby
def remove_validation attribute
  _validators.reject!{ |key, _| key == attribute.intern }

  _validate_callbacks.each do |callback|
    if callback.raw_filter.try(:attributes) == [attribute]
      callback.raw_filter.try(:attributes).delete attribute
    end
  end
end
```

Another way to remove (reset) validation is using `reset_callbacks` method. It will remove all the validations so to skip some validation, you should use `skip_callback` method for that.

```ruby
class Foo < Bar
  Bar.reset_callbacks(:validate)
end
```
