namespace :db do
  namespace :spec do
    desc 'drop database and recreate from test schema'
    task :prepare do
      require File.join(File.dirname(__FILE__), '..', 'lib', 'record_filter')

      db_file = File.join(File.dirname(__FILE__), '..', 'spec', 'test.db')
      FileUtils.rm(db_file) if File.exists?(db_file)

      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => db_file
      )

      ActiveRecord::Schema.define do

        create_table :ads do |t|
          t.integer :blog_id
          t.string :content
        end

        create_table :articles do |t|
          t.string :contents
          t.timestamps
        end

        create_table :assets do |t|
          t.timestamps
          t.string :format
        end

        create_table :asset_attachments do |t|
          t.integer :to_id
          t.string  :to_type
          t.integer :from_id
        end

        create_table :authors do |t|
          t.references :post
          t.string :nickname
          t.references :user
        end

        create_table :blogs do |t|
          t.string :name
          t.boolean :published
          t.integer :special_id
          t.timestamps
        end

        create_table :comments do |t|
          t.references :post
          t.references :user
          t.string :contents
          t.boolean :offensive
          t.timestamps
        end

        create_table :features do |t|
          t.references :blog
          t.integer :featurable_id
          t.string :featurable_type
          t.integer :priority
        end

        create_table :news_stories do |t|
          t.references :blog
          t.string :permalink
          t.text :contents
        end

        create_table :photos do |t|
          t.integer :post_id
          t.string :path
          t.string :format
        end

        create_table :posts do |t|
          t.integer :blog_id
          t.integer :special_blog_id
          t.string :permalink
          t.timestamp :created_at
          t.boolean :published
          t.string :content
          t.string :title
        end

        create_table :posts_tags, :id => false do |t|
          t.integer :post_id
          t.integer :tag_id
        end

        create_table :reviews do |t|
          t.integer :reviewable_id
          t.string :reviewable_type
          t.integer :stars_count
        end

        create_table :subscriptions do |t|
          t.string :email
          t.timestamps
        end

        create_table :tags do |t|
          t.string :name
        end

        create_table :users do |t|
          t.string :first_name
          t.string :last_name
          t.string :email_address
        end
      end
    end
  end
end
