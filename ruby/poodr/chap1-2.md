#Practical Object-Oriented Design in Ruby

##1. Object-Oriented Design

Object-oriented applications are made up of parts, which are objects, that interact to make a running system. The interactions between objects are the _messages_ that pass between them. Getting the right message from the correct object **requires** the **sender** of the message **know things about the receiver**. **This knowledge creates dependencies between the two** and it stand in the way of change.

Object-oriented design **is about managing dependencies**. It is a _set of coding technique_ that _arrange dependencies_ such that objects can tolerate change. Unmanaged dependencies will make the system parts, which is object, hard to change. Changing one object forces change upon its collaborators and so on.

The code's arrangement is the _design_. Code arrangement can be arranged in different ways.

Practical design does not anticipate what will happen to the application, it merely accepts that something will happen to the application, which is obscure by now. It preserves options for accommodating the future, leaves room to change.

The purpose of design is to allow you to do **design later** and its primary goal is to **reduce the cost of change**.

###The tools of design

- Design principal

- Design Patterns

###The Act of Design

**How design fails**

The first way design fails is due to lack of it. Programmers initially know little about the design. They can write codes that meet the requirements and run successfully. But undesigned applications carry the seeds of their own destruction: they are easy to write but gradually become impossible to change.

Experienced programmer also encounter different design failures. These programmers are aware of OO design techniques but do not yet understand how to apply them. They fall into the trap of _overdesign_, they apply principles inappropriately and see patterns where none exist.

Finally, object-oriented software fails when the act of design is separated from the act of programming. Design is a **process of progressive discovery** that **relies on a feedback loop**. This feedback loop should be **timely and incremental**, thus it is suit with Agile software methodology.

##2. Designing class with a Single Responsibility

Class is the organizational structure of code in an object-oriented system. So, it is important to know how to decide what belongs in a class.

###Deciding What Belongs in a Class

####Organizing Code to Allow for Easy Changes

Easy change should be:

  - Changes have no unexpected side effects

  - Small changes in requirements require correspondingly small changes in code

  - Existing code is easy to reuse

  - The easiest way to make a change is to add code that in itself is easy to change.

Then the code should have the following qualities:

  - **Transparent** The consequences of change should be obvious in the code that is changing and in distant code relies upon it (no unknown or unforeseen side effect).

  - **Resonable** The cost of any change should be proportional to the benefits the change achieves (not cost too much of time and effort to change the code to achieves something)

  - **Useable** Existing code should be usable in new and unexpected contexts

  - **Exemplary** The code itself should encourage those who change it to perpetuate these qualities

The first step in creating code that is Transparent, Reasonable, Usable, and Exemplary (TRUE) is to ensure that each class has a single, well-defined responsibility.

###Create Single Responsibility Classes

####An Example Application: Bicycles and Gears

This example is about gear and bicycle. Gear is a part of bicycle and it changes the distance that the bicycle traveled each time the pedals complete a circle. More specifically, your gear controls how many times the wheels rotate for each time the pedals rotate. With small gear, the pedal has to spin several times to make the wheels rotate just once; in a big gear each complete pedal rotation may cause the wheels to rotate multiple times.

To compare different gears. bicyclists use the ratio of the numbers of their teeth. These ratio can be calculated with this simple formula:

    ratio = chainring / cog

The application here will be used to calculate gear ratios:

```ruby
class Gear
  attr_reader :chainring, :cog
  def initialize chainring, cog
    @chainring = chainring
    @cog = cog
  end

  def ratio
    chainring / cog.to_f
  end
end

puts Gear.new(52, 11).ratio        # -> 4.72727272727273
puts Gear.new(30, 27).ratio        # -> 1.11111111111111
```

But then, there are bicycles which have the same gear ratio but have different wheel sizes. So, there is a need to calculate the effect of the difference wheel size.

Cyclists use gear inches to compare bicycles that differ in both gearing and wheel size. The formula follows:

    gear inches = wheel diameter * gear ratio

where

    wheel diameter = rim diameter + twice tire diameter.

The code is changed to:

```ruby
class Gear
   attr_reader :chainring, :cog, :rim, :tire
   def initialize chainring, cog, rim, tire
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    # tire goes around rim twice for diameter
    ratio * (rim + (tire * 2))
  end
end

puts Gear.new(52, 11, 26, 1.5).gear_inches
# -> 137.090909090909

puts Gear.new(52, 11, 24, 1.25).gear_inches
# -> 125.272727272727
```

The `gear_inches` methods assumes that rim and tire sizes are given in inches, which may or may not be correct. And the new `Gear` class will cause the following bugs:

```
puts Gear.new(52, 11).ratio  # didn't this used to work?
# ArgumentError: wrong number of arguments (2 for 4)
```

This is because when the `gear_inches` method added, the `Gear` `initialize` was changed to require two additional arguments (rim and tire). **Altering the number of arguments that a method requires breaks all existing callers of the method**.

So, the gear class now is pretty good if the application is static. But if the application grow, `Gear` is the class that is most likely to change and it need to be easy for changing.

#####Why Single Responsibility Matters

Applications that are easy to change consist of classes that are easy to reuse. Reusable classes are **pluggable unit** of **well-defined behavior** that have **few entanglements**.

A class that has more than one responsibility is difficult to reuse. The various responsibility are likely thoroughly entangled _within_ the class. If some part (behavior) of a class (not all) is needed, it is impossible to get just the parts needed from the class.

When a class contains several tangled up responsibilities, it has many reason to change. It may change for a reason that is unrelated to what it's used for, and each time it changes there's a possibility of breaking every class that depend on it.

#####Determining If a class has a Single Responsibility

How to determine if the `Gear` class contains behavior that belongs to somewhere else? One way is to pretend `Gear` as a person and ask it questions. Question like: _what is your ratio?_ seems perfectly reasonable, while _what are your gear inches?_ is somehow not right and _what is your tire (size)?_ is not good.

From the point of view of every other object, anything that `Gear` can respond to is just another message. If `Gear` respond to it, someone (other object) will send it just like how these question work. So when `Gear` change, the sender may get some unexpected behavior.

Another way is to describing the class in one sentence. If the simplest description of a class uses the word _"and"_, the class likely has more than one responsibility. If it uses the word _"or"_, it definitely has more than one responsibility and they aren't even related.

The word **cohesion** is used to describe this concept. When **everything in a class** is **related** to its **central purpose**, the class is said to be highly cohesive or to have single responsibility.

So the `Gear` class can be describe with: _"Calculate the ratio between two toothed sprockets"_. If this is true then `Gear` currently does too much. With _"Calculate the effect that a gear has on a bicycle"_, the `tire` and `size` are not relevant.

#####When to make design decision

The code in the Gear class is both _transparent_ and _reasonable_, but this does not reflect excellent design, because the class merely has no dependencies. If it were to acquire dependencies it would suddenly be violation of both of those goals. Conveniently, the new dependencies will supply the exact information to make good design decisions.

The structure of every class is a message to future maintainers of the application. It reveals the design intentions. And the intentions pattern that made today might be replicated forever.

`Gear` _lies_ about the intentions. It neither _usable_ nor _exemplary_. It has multiple responsibilities and so should not be reused. It is not a pattern that should be replicated.

####Write code that embrace change

`Gear` code can be arranged so that it will be easy to change to whatever may come. Here are a few well-known techniques that can be used:

#####Depend on Behavior, not Data

_Behavior_ is _captured in methods_ and _invoked_ by _sending messages_. In a class that have a single responsibility, every bit of behavior lives in one and only one place. The phrase _"Don't Repeat Yourself"_ (DRY) is a shortcut for this idea. With DRY code, any change in behavior can be made by changing code in just one place.

In addition to behavior, objects contain data too. Data is held in an instance variable and can be anything from a string or another user-defined object. Data can be access in two way:

  - directly use the instance variable

  - access through accessor method.

_**Hide instance Variables**_

Always wrap instance variables in accessor method instead of directly access. Example with `ratio` method from `Gear` class above.

Hide the variables, even from the class that defines them, by wrapping them in methods. Ruby provides attr_reader as an easy way to create the encapsulating methods.

```ruby
 class Gear
  attr_reader :chainring, :cog  # <-------
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def ratio
    chainring / cog.to_f        # <-------
  end
end
```

`cog` method define the behavior that get the value of cog of a gear. It can be the actual cog value or the derived value from calculate cog value with other formula. Example:

````ruby
def cog
  @cog * (foo? ? bar_adjustment : baz_adjustment)
end
```

Dealing with data as if it’s an object that understands messages introduces two new issues:

  - Visibility: Wrapping the `@cog` instance variable in a public `cog` method exposes this variable to the other objects.

  - Abstract: every variable that wrapped in a method will be treated as just another object. The distinction between _data_ and a _regular object_ begins to disappear.

Data should be hide and by doing so, the code is protected by unexpected changes.

_**Hide Data Structures**_

Example:

```ruby
class ObscuringReferences
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def diameters
    # 0 is rim, 1 is tire
    data.collect {|cell|
      cell[0] + (cell[1] * 2)}
  end
  # ... many other methods that index into the array
end
```

This class expects to be initialized with a two-dimensional array of rims and tires:

    [[622, 20], [622, 23], [559, 30], [559, 40]]

Because `@data` contains a complicated data structure (array of array), and the `data` wrapper method merely return this value. Each sender of `data` must have complete knowledge of what piece of data is at which index in the array.

The `diameters` method knows not only how to calculate diameters, but also the position of rims and tires in the `data` array (rims at data[0] and tires at data[1]).

It _depends_ on the array's structure. If that structure change, then the code (`diameters` method, and the data sender object) must change. And the structure of data array will be referenced in all the sender object. Every sender object must know data[0] is rims value. This knowledge should not be duplicated. Thus the code is not DRY.

Direct references into complicated structures are confusing, because they obscure what the data really is, and they are a maintenance nightmare.

In Ruby, to separate structure from meaning, use `Struct` class to wrap a structure. Example:

```ruby
class RevealingReferences
  attr_reader :wheels
  def initialize(data)
    @wheels = wheelify(data)
  end

  def diameters
    wheels.collect {|wheel| wheel.rim + (wheel.tire * 2)}
  end
  # ... now everyone can send rim/tire to wheel

  Wheel = Struct.new(:rim, :tire)
  def wheelify(data)
    data.collect {|cell| Wheel.new(cell[0], cell[1])}
  end
end
```

The `diameters` method has no knowledge of the internal structure of the array. All it know is that the message `wheels` return an enumerable and that each enumerated element responds to `rim` and `tire`.

All knowledge of the structure of the incoming array has been isolated inside the `wheelify` method, which convert the array of array to array of [Struct](http://ruby-doc.org/core/classes/Struct.html).

Because `wheelify` contains the code that understands the structure of the input array data. If the input changes, the code only change in just one place (`wheelify` method).

#####Enforce Single Responsibility Everywhere

Single Responsibility should be employed in many other parts of the code.

_**Extract Extra Responsibilities from Methods**_

Example: the `diameters` method of class `RevealingReferences`:

```ruby
def diameters
  wheels.collect {|wheel| wheel.rim + (wheel.tire * 2)}
end
```

This method has two responsibilities: iterates over the wheels and calculates the diameter of each wheel.

Simplify the code by separating it into two methods, each with one responsibility.

```ruby
# first - iterate over the array
def diameters
  wheels.collect {|wheel| diameter(wheel)}
end

# second - calculate diameter of ONE wheel
def diameter(wheel)
  wheel.rim + (wheel.tire * 2)
end
```

Sometime it's not obvious to figure a method that have multiple responsibility. Example: the `gear_inches` method from `Gear`

```ruby
def gear_inches
  # tire goes around rim twice for diameter
  ratio * (rim + (tire * 2))
end
```

Hidden inside gear_inches is the calculation for wheel diameter. Extracting that calculation into this new diameter method will make it easier to examine the class’s responsibilities:

```ruby
def gear_inches
  ratio * diameter
end

def diameter
  rim + (tire * 2)
end
```

This simple refactoring makes the problem obvious. `Gear` is definitely responsible for calculating gear_inches, but it should not calculating wheel diameter.

Methods that have a single responsibility confer the following benefits:

  - **Expose previously hidden qualities** Refactoring a class so that all of its methods have a single responsibility has a clarifying effect on the class.

  - **Avoid the need for comments**

  - **Encourage reuse**

  - **Are easy to move to another class**

_**Isolate Extra Responsibilities in Classes**_

`Gear` class now have some wheel-like behaviour. The question here is: Does this app need a `Wheel` class?

`Gear` seems like can't have a single responsibility unless the wheel-like behaviour is removed from it; the extra behaviour is either in `Gear` or not. The goal here is to _preserve_ single responsibility in `Gear` while making the fewest design commitments possible. _**Any decisions that made in advance of an explicit requirement is just a guess**_. Don't decide; preserve the _ability_ to _make a decision later_.

Ruby allows you to remove the responsibility for calculating tire diameter from Gear without committing to a new class

```ruby
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @wheel     = Wheel.new(rim, tire)
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    ratio * wheel.diameter
  end

  Wheel = Struct.new(:rim, :tire) do
    def diameter
      rim + (tire * 2)
    end
  end
end
```

Embedding this `Wheel` in `Gear` is obviously not the long-term design goal; it’s more an _experiment in code organization_.

Embedding `Wheel` inside og `Gear` suggest that `Wheel` only exist in the context of a `Gear`. In this case, the creation for `Wheel` class is needed. However, every domain isn’t this clear-cut.

If a muddled class with too many responsibilities, separate those responsibilities into different classes. Concentrate on the primary class. If an extra responsibilities that cannot yet remove, isolate them.

**The real Wheel**

The newest requirement come: "calculate bicycle wheel circumference". With that requirement, the real `Wheel` class is needed to be created. And simply convert the Wheel Struct to a `Wheel` class and add new `circumference` method:

```ruby
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel=nil)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    ratio * wheel.diameter
  end
end

class Wheel
  attr_reader :rim, :tire

  def initialize(rim, tire)
    @rim       = rim
    @tire      = tire
  end

  def diameter
    rim + (tire * 2)
  end

  def circumference
    diameter * Math::PI
  end
end

@wheel = Wheel.new(26, 1.5)
puts @wheel.circumference
# -> 91.106186954104

puts Gear.new(52, 11, @wheel).gear_inches
# -> 137.090909090909

puts Gear.new(52, 11).ratio
# -> 4.72727272727273
```
