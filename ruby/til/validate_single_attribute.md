#Rails validate single attribute
================================

To validate only one attribute (field) of an ActiveRecord model, use `validators_on` of `ActiveModel::Validations`.

```
validators_on(*attributes): list all validators that are being used to validate a specific attribute.
```

Example:

``` ruby
class User
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
```

To validate only email:

``` ruby
def validate_email(value)
  User.validators_on(:email).each do |validator|
    validator.validate_each self, :email, value
  end
end
```

To validate only uniqueness behaviour of email:

``` ruby
def validate_email_unique value
  validator = User.validators_on(:email).find do |v|
    v.class == ActiveRecord::Validations::UniquenessValidator
  end
  validator.validate_each(self, :email, value).blank?
end
```

