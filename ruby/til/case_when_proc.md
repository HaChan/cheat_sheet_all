From Ruby 1.9 toward, `Proc#===` method is an alias to `Proc#call` method. This  mean Proc object can be used in case statements like so:

```ruby
eq_1000 = ->(a){1000 == a}

case number
when eq_1000
  # Do something
end

# instead of

case number
when eq_1000.call number
  # Do something
end
```
