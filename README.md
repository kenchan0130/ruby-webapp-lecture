# sinatra web app
Sinatra を使用して投稿ができる Web アプリケーションを作成してみましょう。


## 前提条件
以下がインストールされている必要があります。

- ruby
	- 2.3.x を推奨
- bundler
- sqlite3

## Rubygems の準備

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'sqlite3'
gem "sinatra-activerecord"
gem 'sinatra'
gem 'sinatra-contrib'
gem 'rake'

group :development do
  gem 'pry-byebug'
end
```

`bundle` コマンドで gem たちをインストールしてみましょう。

```sh
bundle install --path=vendor/bundle
```

`--path` は Rubygems のインストール先の指定です。
指定しない場合はグローバルにインストールされます。
(つまり、 `gem install xxx` を行っているのと同じです)


## skeleton の作成
```ruby
# app.rb
require 'sinatra/contrib'

module MyApp
  class Application < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      'Hello, Sinatra'
    end
  end
end
```

```ruby
# config.ru
require 'bundler'

groups = %W(default #{ENV['RACK_ENV']})
Bundler.require(*groups)

require './app'
run MyApp::Application
```

```sh
bundle exec rackup
```

localhost:9292 にアクセスして、「Hello, Sinatra」が表示されていることを確認してみましょう。

port 番号を変更したい場合は `-p` または `--port` の後に port 番号をしていすればよいです。

## データベースの設定
データを永続化するために database の設定をしましょう。

### Rakefile の設定
`rake` とは `make` を Ruby で実装したものです。
最初のうちは、様々なタスクを定義できるタスクランナーであると考えていただいて構いません。


```ruby
# Rakefile
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

require './app'
```

`Rakefile` を設定したことで、様々なタスクを実行できるようになりました。

```sh
bundle exec rake -T
```

### データベースの作成

```yaml
# config/database.yml
development:
  adapter: sqlite3
  database: db/my_app.db
```

```sh
bundle exec rake db:create
```

データベースが作成されます。

### table の設定

投稿を管理するテーブルを作ってみましょう。

```sh
bundle exec rake db:create_migration NAME=create_posts
```

```ruby
# db/migrate/xxxxx_create_posts.rb
class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.string :title,    null: false
      t.string :contents, null: false

      t.timestamps
    end
  end
end
```

```sh
bundle exec rake db:migrate
```

でマイグレーション(テーブル作成)ができます。

## Ruby とデータベースのテーブルの紐付け
テーブルと ruby を紐づける処理を書きます。

```ruby
# models/post.rb
class Post < ActiveRecord::Base
end
```

## 一覧の表示
```ruby
# app.rb
require 'sinatra/contrib'

# モデルの呼び出し
require './models/post'

module MyApp
  class Application < Sinatra::Base
    configure do
      register Sinatra::ActiveRecordExtension
      set :database_file, 'config/database.yml'
    end

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      'Hello, Sinatra'
    end

	get '/posts' do
	  @posts = Post.all
	  erb :'posts/index'
	end
  end
end
```

```html
<%# views/posts/index.erb %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>sintra sample</title>
  </head>
  <body>
    <% if @posts.empty? %>
      一件も投稿がありません
    <% else %>
      <ul>
      <% @posts.each do |post| %>
        <li>
        <%= post.title %>
        </li>
      <% end %>
      </ul>
    <% end %>
    <a href="/posts/new">投稿画面へ</a>
  </body>
</html>
```

一度、 `localhost:9292/posts` にアクセスしてみて、表示されるか確認してみましょう。

```sh
bundle exec rackup
```

## 新規作成画面の作成
```ruby
# app.rb
require 'sinatra/contrib'

require './models/post'

module MyApp
  class Application < Sinatra::Base
    configure do
      register Sinatra::ActiveRecordExtension
      set :database_file, 'config/database.yml'
    end

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
	  'Hello, Sinatra'
    end

	get '/posts' do
	  @posts = Post.all
	  erb :'posts/index'
	end

    get '/posts/new' do
      @post = Post.new
      erb :'posts/new'
    end
  end
end
```

```html
<%# views/posts/new.erb %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>sample</title>
  </head>
  <body>
    <form action="/posts" method="post">
      <div>
        タイトル:<input type="text" name="title" value="">
      </div>
      <div>
        本文:
        <textarea name="contents" rows="5"></textarea>
      </div>
      <div>
        <input type="submit" value="投稿する">
      </div>
    </form>
  </body>
</html>
```

再度表示されるか確認してみましょう。

```sh
bundle exec rackup
```


## 投稿処理の作成
```ruby
# app.rb
require 'sinatra/contrib'

require './models/post'

module MyApp
  class Application < Sinatra::Base
    configure do
      register Sinatra::ActiveRecordExtension
      set :database_file, 'config/database.yml'
    end

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
	  'Hello, Sinatra'
    end

	get '/posts' do
	  @posts = Post.all
	  erb :'posts/index'
	end

    get '/posts/new' do
      @post = Post.new
      erb :'posts/new'
    end

    post '/posts' do
      @post = Post.create!(title: params[:title], contents: params[:contents])
      erb :'posts/create'
    end
  end
end
```

```html
<%# views/posts/create.erb %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>sample</title>
  </head>
  <body>
    <div>
      タイトル:<%= @post.title %>
    </div>
    <div>
      本文；<%= @post.contents %>
    </div>
    <a href="/posts">一覧に戻る</a>
  </body>
</html>
```

実際投稿できるか確認してみましょう。

```sh
bundle exec rackup
```
