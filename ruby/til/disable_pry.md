##Skip Pry in a loop

When using `binding.pry` (`gem pry-rails`) inside a loop, like this:

```ruby
(1..100).each do |i|
  binding.pry
  puts i
end
```

To exit `pry` and keep the program running, use:

    disable-pry
