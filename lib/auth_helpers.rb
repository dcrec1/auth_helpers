module AuthHelpers
  # Helper that find or initialize an object by attribute only if the given value
  # is not blank. If it's blank, create a new object using :new.
  #
  def self.find_or_initialize_by_unless_blank(klass, attr, value)
    if value.blank?
      klass.new
    else
      klass.send(:"find_or_initialize_by_#{attr}", value)
    end
  end

  # Creates a new record, assigning the perishable token and an error message.
  #
  def self.new_with_perishable_token_error(klass, message=:invalid, options={})
    record = klass.new(options)
    record.perishable_token = options[:perishable_token]
    record.errors.add(:perishable_token, message, :default => [:invalid])
    record
  end

end
