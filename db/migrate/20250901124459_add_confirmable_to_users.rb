class AddConfirmableToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :confirmation_token,   :string   unless column_exists?(:users, :confirmation_token)
    add_column :users, :confirmed_at,         :datetime unless column_exists?(:users, :confirmed_at)
    add_column :users, :confirmation_sent_at, :datetime unless column_exists?(:users, :confirmation_sent_at)
    # add_column :users, :unconfirmed_email,    :string   # если включишь reconfirmable

    add_index :users, :confirmation_token, unique: true unless index_exists?(:users, :confirmation_token)

    # Бэкфилл: помечаем всех текущих пользователей как подтверждённых,
    # чтобы их не «запереть». Если не нужно — закомментируй строку ниже.
    execute <<~SQL
      UPDATE users SET confirmed_at = NOW() WHERE confirmed_at IS NULL;
    SQL
  end

  def down
    remove_index  :users, :confirmation_token if index_exists?(:users, :confirmation_token)
    remove_column :users, :confirmation_token   if column_exists?(:users, :confirmation_token)
    remove_column :users, :confirmed_at         if column_exists?(:users, :confirmed_at)
    remove_column :users, :confirmation_sent_at if column_exists?(:users, :confirmation_sent_at)
    # remove_column :users, :unconfirmed_email   if column_exists?(:users, :unconfirmed_email)
  end
end
