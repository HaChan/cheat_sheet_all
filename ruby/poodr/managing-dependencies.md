#Managing Dependencies

In object oriented programs, tasks are done by multiple object collaborating with each other. And also because well designed objects have a single responsibility, they have to collaborate to accomplish complex tasks. This collaboration is powerful and perilous. An object must know something about another object in order to collaborate. This knowledge create dependencies. If not managed carefully, these dependencies will make it hard to maintain.

- [Understanding Dependencies](#understanding-dependencies)

  - [Recognizing Dependencies](#recognizing-dependencies)

  - [Coupling Between Objects](#coupling-between-objects)

  - [Other Dependencies](#other-dependencies)

- [Writing Loosely Coupled Code](#writing-loosely-coupled-code)

  - [Inject Dependencies](#inject-dependencies)

  - [Isolate Dependencies](#isolate-dependencies)

    - [Isolate Instance Creation](#isolate-instance-creation)

    - [Isolate Vulnerable External Messages](#isolate-vulnerable-external-messages)

  - [Remove Argument-Order Dependencies](#remove-argument-order-dependencies)

    - [Use Hashes for Initialization Arguments](#use-hashes-for-initialization-arguments)

    - [Explicitly Define Defaults](#explicitly-define-defaults)

    - [Isolate Multiparameter Initialization](#isolate-multiparameter-initialization)

- [Managing Dependency Direction](#managing-dependency-direction)

  - [Reversing Dependencies](#reversing-dependencies)

  - [Choosing Dependency Direction](#choosing-dependency-direction)

    - [Understanding Likelihood of Change](#understanding-likelihood-of-change)

    - [Recognizing Concretions and Abstractions](#recognizing-concretions-and-abstractions)

    - [Finding the dependencies that matter](#finding-the-dependencies-that-matter)

##Understanding Dependencies

An object depends on another object if, when one object changes, the other might be forced to change in turn.

Let's consider this example:

```ruby
class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @rim       = rim
    @tire      = tire
  end

  def gear_inches
    ratio * Wheel.new(rim, tire).diameter
  end

  def ratio
    chainring / cog.to_f
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
end

Gear.new(52, 11, 26, 1.5).gear_inches
```

With this example, `Gear` would be forced to change because of a change to `Wheel`. `Gear` has at least four dependencies on `Wheel` and these dependencies are common mistake made by side effect of the coding style. Their very existence weakens Gear and makes it harder to change.

###Recognizing Dependencies

An object has a dependency when it knows:

  - **The name of other class**. `Gear` expects a class named `Wheel` to exist.

  - **The name of a message that it intends to send to some object other than _self_**. `Gear` expects a `Wheel` instance to respond to `diameter`.

  - **The arguments that a message requires**. `Gear` knows that `Wheel.new` requires a `rim` and a `tire`.

  - **The order of those arguments**. Gear knows the first argument to `Wheel.new` should be `rim`, the second `tire`.

Because objects has to collaborate, dependencies between these classes are inevitable, but most of the dependencies listed above are unnecessary. They make the code less reasonable, and make the class hard to change.

Design challenge is to manage dependencies so that each class has the fewest possible. A class should know just enough to do its jobs.

###Coupling Between Objects

`Gear` and `Wheel` are coupled by these dependencies. The more Gear knows about Wheel, the more tightly coupled they are. The more tightly coupled two objects are, the more they behave like a single entity.

If `Wheel` changed so `Gear` is necessary needed to change. If `Gear` is reused, `Wheel` comes along too. When testing `Gear`, `Wheel` need to be tested too.

When objects are tightly coupled, they behave like a unit, it's impossible to reuse just one. Changes to one object force changes to all.

###Other Dependencies

There are others dependencies beside these four dependencies that listed above. First, the dependency happen when an object knows another object who knows other who knows something; that is where many messages are chained together to reach behavior that lives in a distant object. This is the same with the _"The name of a message that it intends to send to some object other than self"_ but it is magnified. Message chaining creates a _dependency between_ the _original object_ and _every object and message along the way_ to its ultimate target.

This is the case that violate the Law of Demeter and need its own special treatment [Creating Flexible interfaces]().

Another class of dependencies is that of the tests on code. Test refer to code and thus depend on code. This tight coupling leads to incredible frustration; the tests break every time the code is refactored, even when the fundamental behavior of the code does not change.

##Writing Loosely Coupled Code

Dependency is necessary to glue the classes together but too much of dependencies will make the application sticky and hard to change. Reducing dependencies means recognizing and removing the ones that is redundant.

###Inject Dependencies

Let's examine the `gear_inches` method of `Gear`:

```ruby
def gear_inches
   ratio * Wheel.new(rim, tire).diameter
end
```

Here, `Wheel` is refer directly in the `gear_inches` method of `Gear` class. The obvious consequence of the reference is that if `Wheel` changes its name, `gear_inches` method must also change.

Dealing with the name change is a minor issue. When `Gear` hard-codes a reference to `Wheel` inside `gear_inches` method, the `Gear` now is only willing to calculate gear inches for instances of `Wheel`. Gear refuses to collaborate with any other kind of object, even if that object has a diameter and uses gears.

`Gear` only need to know which object can respond to `diameter` method. It doesn't care and should not know about the class of the object.

Gear becomes less useful when it knows too much about other objects; if it knew less it could do more.

Instead of being glued to `Wheel`, this next version of `Gear` expects to be initialized with an object that can respond to `diameter`:

```ruby
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end

  def gear_inches
    ratio * wheel.diameter
  end
# ...
end

# Gear expects a 'Duck' that knows 'diameter'
Gear.new(52, 11, Wheel.new(26, 1.5).gear_inches
```

`Gear` can now collaborate with any object that implements `diameter`.

This technique is known as _dependency injection_. `Gear` previously had explicit dependencies on the `Wheel` class, but through injection these dependencies have been reduced to a single dependency on the `diameter` method.

Using dependency injection to shape code relies on the ability to recognize that the responsibility for _knowing the name of a class_ and the responsibility for _knowing the name of a message to send to that class_ **may belong in different objects**. Just because `Gear` needs to send `diameter` does not mean that `Gear` should know about `Wheel`.

This leaves the question of where the responsibility for knowing the actual `Wheel` class lies. [marked ----------------------]()

###Isolate Dependencies

In the real world, it is not always possible to break all unnecessary dependencies. When working on an exiting application, there are several constraints that prevent changes. For instance: `Gear`'s initialization that take 4 arguments `chainring`, `cog`, `rim` and `tire` is used all over the place in the application, so it's hard to refactor it to remove dependencies.

Therefore, dependencies should be isolated within the class. Like with the case of Single Responsibility class when extraneous responsibilities are isolated so that they would be easy to recognize and remove when the right impetus came.

####Isolate Instance Creation

In the `Gear` case, the creation of `Wheel` need to be isolated. The intent is to explicitly expose the dependency while reducing its reach into the `Gear` class

There are two way of isolating instance creation:

First, move the creation of `Wheel` from `gear_inches` method to Gear's initialize method. This clean up the `gear_inches` method and publicly exposes the dependency in the `initialize` method.

```ruby
class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @wheel     = Wheel.new(rim, tire)
  end

  def gear_inches
    ratio * wheel.diameter
  end
end
```

The next alternative way is creating `Wheel` in its own explicitly `wheel` method.

```ruby
class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @rim       = rim
    @tire      = tire
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def wheel
    @wheel ||= Wheel.new(rim, tire)
  end
end
```

These coding styles reduce the number of dependencies in `gear_inches` while publicly exposing Gear’s dependency on `Wheel`. They reveal dependencies instead of concealing them, lowering the barriers to reuse and making the code easier to refactor when circumstances allow.

####Isolate Vulnerable External Messages

The external messages are the one that _send to someone other than self_. Example: the `gear_inches` method below sends `ratio` and `wheel` to `self`, but send `diameter` to `wheel`:

```ruby
def gear_inches
  ratio * wheel.diameter
end
```

If this method contains only one reference to `wheel.diameter`, it has no problem at all. But when `gear_inches` required complex operation that may turn out like this:

```ruby
def gear_inches
  #... a few lines of scary math
  foo = some_intermediate_result * wheel.diameter
  #... more lines of scary math
end
```

Now `wheel.diameter` is embedded deeply inside a complex method. Embedding this external dependency inside the `gear_inches` method is unnecessary and increases its vulnerability.

So, the external dependency `wheel.diameter` can be encapsulating in a method of its own:

```ruby
def gear_inches
  #... a few lines of scary math
  foo = some_intermediate_result * diameter
  #... more lines of scary math
end

def diameter
  wheel.diameter
end
```

The new `diameter` can DRY the reference of `wheel.diameter` sprinkled throughout `Gear`. The creation of `diameter` is followed by the Single Responsibility Principle. Each method should have only one responsibility. And with the original `gear_inches`, it do both the calculating gear inches and the mechanism to get the `diameter` from `wheel`. After this change, `gear_inches` is more abstract. Gear now isolates `wheel.diameter` in a separate method and `gear_inches` can depend on a message sent to self.

This technique becomes necessary when a class contains embedded references to a _message_ that is _likely to change_. Isolating the reference provides some insurance against being affected by that change

###Remove Argument-Order Dependencies

When sending messages that requires arguments, sender cannot avoid having knowledge of those arguments. This dependency is unavoidable. However, this introduced another dependency that is the fixed order of the arguments.

Example:

```ruby
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end
end

Gear.new(52, 11, Wheel.new(26, 1.5)).gear_inches
```

When a new instance of Gear is created, the arguments must be passed _in the correct order_. Senders of `new` depend on the order of the arguments as they are specified in Gear's `initialize` method. If that order changes, senders will be forced to change.

####Use Hashes for Initialization Arguments

If the method is controllable (freely change and modify), change it to take a hash of options instead of a fixed list of parameters.

Example: change Gear's `initialize` to takes one `args` arguments, a hash that contains all of the inputs.

```ruby
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
  end
end

Gear.new(
  :chainring => 52,
  :cog       => 11,
  :wheel     => Wheel.new(26, 1.5)).gear_inches
```

The above technique removes every dependency on argument order. Gear is now free to add or remove initialization arguments and defaults, secure in the knowledge that no change will have side effects in other code.

The second benefit is that the key names in the hash furnish explicit documentation about the arguments. Future maintainers of this code will be grateful for the information.

The benefit of this technique based on the personal situation. If the method parameter list is lengthy and wildly unstable, like in a framework that is is intended to be used by other, it will archive the above benefit. However, when a method is simple like multiplies two numbers, it's far simpler and cheaper to merely pass the arguments and accept the dependency on order..

Between these two extremes lies a common case, that of the method that requires a few very stable arguments and optionally permits a number of less stable ones. In this case, the most cost-effective strategy may be to use both techniques; that is, to take a few fixed-order arguments, followed by an options hash.

####Explicitly Define Defaults

Let's examine techniques for adding default values. First is using Ruby's `||` method for _non-boolean_ value:

```ruby
def initialize(args)
  @chainring = args[:chainring] || 40
  @cog       = args[:cog]       || 18
  @wheel     = args[:wheel]
end
```

The `||` method acts as boolean `or` operation; it first evaluates the left-hand expression and then, if the expression returns `false` or `nil`, proceeds to evaluate and return the result of the right-hand expression. The use of || above therefore, relies on the fact that the [] method of Hash returns nil for missing keys.

This method doesn't work well the wanted value is `false` or `nil` because it will proceeds to evaluate and return the result of the expression after `||`. Example:

```ruby
@bool = args[:boolean_thing] || true
```

In here, `@bool` can never be assigned to `false`.

The other approach is using `fetch` method of Hash instead of `[]` with `||`. The `fetch` method expects the key to be fetched in the hash and supplies several options for handling missing keys. Example:

```ruby
def initialize(args)
  @chainring = args.fetch(:chainring, 40)
  @cog       = args.fetch(:cog, 18)
  @wheel     = args[:wheel]
end
```

The defaults can be completely removed from `initialize` and isolated them inside a separate wrapping method. Example:

```ruby
def initialize(args)
  args = defaults.merge(args)
  @chainring = args[:chainring]
  ...
end

def defaults
  {:chainring => 40, :cog => 18}
end
```

The `defaults` method defines a second hash that is merged into the options hash during initialization. The `merge` method of Hash only merge the `defaults`'s keys that are not in the args hash.

_If the defaults are more than simple numbers or strings, implement a defaults method_.

####Isolate Multiparameter Initialization

Sometimes you will be forced to depend on a method that requires fixed-order arguments where you do not own and thus cannot change the method itself.

Imagine that `Gear` is part of a framework and its initialization requires fixed-order arguments. So Gear's `initialize` method is out of your hands to change directly.

In this situation, you can DRY out the creation of new `Gear` instances by creating a method to wrap the Gear's `initialize` method. Example:

```ruby
module SomeFramework
  class Gear
    attr_reader :chainring, :cog, :wheel
    def initialize(chainring, cog, wheel)
      @chainring = chainring
      @cog       = cog
      @wheel     = wheel
    end
  # ...
  end
end

# wrap the interface to protect yourself from changes
module GearWrapper
  def self.gear(args)
    SomeFramework::Gear.new(args[:chainring],
                            args[:cog],
                            args[:wheel])
  end
end

# Now you can create a new Gear using an arguments hash.
GearWrapper.gear(
  :chainring => 52,
  :cog       => 11,
  :wheel     => Wheel.new(26, 1.5)).gear_inches
```

There are two things to note about the `GearWrapper`. First, using a module here doesn't require `GearWrapper` instances and `GearWrapper` itself is representing the object that receive the `gear` message to create a `Gear` instance.

`GearWrapper` sole purpose is to create instances of some other class. It's called _factories_. A factory object is object whose purpose is to create other objects.

The above technique for substituting an options hash for a list of fixed-order arguments is perfect for cases where you are forced to depend on external interfaces that you cannot change.

##Managing Dependency Direction

###Reversing Dependencies

Every example used thus far shows `Gear` depending on `Wheel` or `diameter`, but `Wheel` can be depending on `Gear` as well. This is the reversed dependency direction. `Wheel` could instead depend on `Gear` or `ratio`. Example:

```ruby
 class Gear
  attr_reader :chainring, :cog
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def gear_inches(diameter)
    ratio * diameter
  end

  def ratio
    chainring / cog.to_f
  end
#  ...
end

class Wheel
  attr_reader :rim, :tire, :gear
  def initialize(rim, tire, chainring, cog)
    @rim       = rim
    @tire      = tire
    @gear      = Gear.new(chainring, cog)
  end

  def diameter
    rim + (tire * 2)
  end

  def gear_inches
    gear.gear_inches(diameter)
  end
#  ...
end

Wheel.new(26, 1.5, 52, 11).gear_inches
```

The choices of dependencies direction are critical to your application. If you get this right, your application will be pleasant to work on and easy to maintain. If you get it wrong then the dependencies will gradually take over and the application will become harder and harder to change.

###Choosing Dependency Direction

You should **depend on things that change less often than you do**. This statement is based on three simple truths about code:

  - Some classes are more likely than others to have changes in requirements.

  - Concrete classes are more likely to change than abstract classes.

  - Changing a class that has many dependents will result in widespread consequences.

####Understanding Likelihood of Change

The idea that some classes are more likely to change than others applies to all the code that you **write and used**. The Ruby base classes and the other framework code both have their own inherent likelihood of change.

Ruby base classes change less often than your code. You can depend on them without another thought.

Framework classes depend on the maturity of the framework. In general, any framework will be more stable than the code you write, but if it's undergoing such rapid development that its code changes more often than yours.

Every class used in your application can be ranked along a scale of how likely it is to undergo a change relative to all other classes. This ranking is one of information to consider when choosing the direction of dependencies.

####Recognizing Concretions and Abstractions

The term abstract is used here just as Merriam-Webster defines it:

> disassociated from any specific instance

This concept was illustrated through the injecting dependencies section. There, when `Gear` depend on `Wheel`, it depended on extremely concrete code. After the code was altered to use injection dependency, `Gear` now depend on something more abstract, that is the object that can respond to `diameter` message.

With dynamic typed language, this can be archive easily. But with static typed language like Java, it is hard to inject any random object into one because statically typed languages have compilers that act like unit tests for types. Instead, static typed language use _interface_, that define necessary method and then include to class.

The abstractions represent common and stable qualities. They are less likely to change than the concrete classes. Depending on an abstraction is always safer than depending on a concretion.

####Finding the dependencies that matter

Classes vary in their **likelihood of change**, their **level of abstraction**, and their **number of dependents**. Each quality matters, but the interesting decisions occur at the place where **likelyhood of change** intersects with **number of dependents**. There are 4 zone of combinations marked as A, B, C and D.

  - Zone A: classes that have little likelihood of change but contain many dependents. This Zone usually contains abstract classes or interfaces. Because abstraction are more stable and less likely to change, it allows more dependents to be included in.

  - Zone B: classes in this zone rarely change and have few dependents.

  - Zone C: It is the opposite of Zone A. Zone C contains code that is quite likely to change but has few dependents. These classes tend to be more concrete and have few dependents. And because of that, it doesn't matter that these classes are likely to change because the lack of dependencies.

  - Zone D: A class ends up in Zone D when it is guaranteed to change and has many dependents. Changes to Zone D are costly and may become coding nightmare. A class that is concrete and has many dependencies is the typical type of class in Zone D.
