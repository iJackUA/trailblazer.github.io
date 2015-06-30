---
layout: default
---

# Operation API

## The `params` Hash

Wherever `params` is referenced, think of an input hash in terms of the `params` hash in a controller.

## Operation



Get the form object.

{% highlight ruby %}
form = Thing::Create.present(params).contract
{% endhighlight %}


## Process

The `#process` method is the pivot of any operation. Here, business logic and validations get executed and dispatched.

Its only argument is the `params` hash being passed into `Op.()`. Note that you don't even have to use a contract.

{% highlight ruby %}
class Comment < ActiveRecord::Base
  class Create < Trailblazer::Operation
    def process(params)
      # do whatever you feel like.
    end
  end
end
{% endhighlight %}

## Model Setup

## Validate

You can instantiate you contract manually and invoke validation by hand.

{% highlight ruby %}
def process(params)
  contract = contract_class.new(model)

  if contract.validate(params[:comment])
    # success.
    contract.sync
  else
    # invalid.
  end
end
{% endhighlight %}

Operation provides the `validate` method to do just that for you.

{% highlight ruby %}
def process(params)
  if validate(params[:comment])
    # success.
    contract.sync
  else
    # invalid.
  end
end
{% endhighlight %}

The block syntax will execute block only when valid and is an alternative to the above.

{% highlight ruby %}
def process(params)
  validate(params[:comment]) do |f|
    # success.
    f.sync
    return
  end

  # invalid.
end
{% endhighlight %}

The signature is `validate(params, model, contract_class)`.


## Marking Operation as Invalid

Sometimes you don't need a form object but still want the validity behavior of an operation.

```ruby
def process(params)
  return invalid! unless params[:id]

  Comment.find(params[:id]).destroy
  self
end
```

`#invalid!` returns `self` per default but accepts any result.


## Rendering Operation's Form

You have access to an operation's form using `::present`.

```ruby
Comment::Create.present(params)
```

This will run the operation's `#process` method _without_ the validate block and return the contract.


## Additional Model Setup

Override `Operation#setup_model(params)` to add nested objects that can be infered from `params` or are static.

This is called right after `#model!`.

## Validation Errors

You can access the contracts `Errors` object via `Operation#errors`.

## ActiveModel Semantics

When using `Reform::Form::ActiveModel` (which is used automatically in a Rails environment to make form builders work) you need to invoke `model Comment` in the contract. This can be inferred automatically from the operation by including `CRUD::ActiveModel`.

```ruby
class Create < Trailblazer::Operation
  include CRUD
  include CRUD::ActiveModel

  model Comment

  contract do # no need to call ::model, here.
    property :text
  end
```

If you want that in all CRUD operations, check out [how you can include](https://github.com/apotonick/gemgem-trbrb/blob/chapter-5/config/initializers/trailblazer.rb#L26) it automatically.