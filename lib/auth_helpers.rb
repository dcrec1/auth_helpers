module AuthHelpers
  # Helper that find or initialize an object by attribute only if the given value is not blank.
  # If it's blank, create a new object using :new.
  #
  def self.find_or_initialize_by_unless_blank(klass, attr, value)
    if value.blank?
      klass.new
    else
      klass.send(:"find_or_initialize_by_#{attr}", value)
    end
  end

  # Helpers that generates a unique code for the given attribute by checking in
  # the database if the code already exists.
  #
  def self.generate_unique_string_for(klass, attr, length=40)
    begin
      value = AuthHelpers.random_string(length)
    end while klass.send(:"find_by_#{attr}", value)

    value
  end

  # Create a random string with the given length using letters and numbers.
  #
  def self.random_string(length)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

    newpass = ''
    1.upto(length) { |i| newpass << chars.rand }

    return newpass
  end
end
