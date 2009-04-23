module AuthHelpers
  # Helpers to migration:
  #
  #   create_table :accounts do |t|
  #     t.extend AuthHelpers::Migration
  #     
  #     t.authenticable
  #     t.confirmable
  #     t.recoverable
  #     t.rememberable
  #     t.timestamps
  #   end
  #
  # However this method does not add indexes. If you need them, here is the declaration:
  #
  #   add_index "accounts", ["email"],               :name => "email",               :unique => true
  #   add_index "accounts", ["token"],               :name => "token",               :unique => true
  #   add_index "accounts", ["confirmation_code"],   :name => "confirmation_code",   :unique => true
  #   add_index "accounts", ["reset_password_code"], :name => "reset_password_code", :unique => true
  #
  # E-mail index should be slightly changed with you are working with polymorphic
  # associations.
  #
  module Migration

    # Creates email, hashed_password and salt.
    #
    def authenticable
      self.string :email,           :limit => 100, :null => false, :default => ''
      self.string :hashed_password, :limit =>  40, :null => false, :default => ''
      self.string :salt,            :limit =>  10, :null => false, :default => ''
    end

    # Creates confirmation_code, confirmed_at and confirmation_sent_at.
    #
    def confirmable
      self.string   :confirmation_code, :limit =>  40, :null => true
      self.datetime :confirmed_at
      self.datetime :confirmation_sent_at
    end

    # Creates reset_password_code.
    #
    def recoverable
      self.string :reset_password_code, :limit =>  40, :null => true
    end

    # Creates token and token_created_at.
    #
    def rememberable
      self.string   :token, :limit =>  40, :null => true
      self.datetime :token_expires_at
    end

  end
end
