class RemoveProviderAndUidFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string

    if index_exists?(:users, :provider) && index_exists?(:users, :uid)
      remove_index :users, name: "index_users_on_provider_and_uid"
    end
  end
end
