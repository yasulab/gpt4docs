Active Record の関連付け
==========================

本ガイドでは、Active Recordの関連付け機能（アソシエーション）について解説します。

このガイドの内容:

* Active Recordのモデル同士の関連付けを宣言する方法
* Active Recordのモデルを関連付けるさまざまな方法
* 関連付けを作成すると自動的に追加されるメソッドの利用方法

--------------------------------------------------------------------------------


関連付けを使う理由
-----------------

Railsの「関連付け（アソシエーション: association）」は、2つのActive Recordモデル同士のつながりを指します。モデルとモデルの間には関連付けを行なう必要がありますが、その理由はおわかりでしょうか。関連付けを行うことで、自分のコードの共通操作がシンプルになって扱いやすくなります。簡単なRailsアプリケーションを例にとって説明しましょう。このアプリケーションにはAuthor（著者）モデルとBook（書籍）モデルがあります。一人の著者は、複数の書籍を持っています。関連付けを設定していない状態では、モデルの宣言は以下のようになります。

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

ここで、既存の著者が新しい書籍を1件追加したくなったとします。この場合、以下のようなコードを実行する必要があるでしょう。

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

今度は著者を1人削除する場合を考えてみましょう。著者を削除するときは、その著者の書籍もすべて削除されるようにしておきます。

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Active Recordの関連付け機能を使うと、2つのモデルの間につながりがあることを明示的にRailsに対して宣言でき、それによってモデルの操作を一貫させることができます。著者と書籍を設定するコードを次のように書き直せます。

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

上のように関連付けを追加したことで、特定の著者の新しい書籍を1冊追加する作業が以下のように1行で書けるようになりました。

```ruby
@book = @author.books.create(published_at: Time.now)
```

著者と、その著者の書籍をまとめて削除する作業は**ずっと**簡単です。

```ruby
@author.destroy
```

その他の関連付け方法については、次のセクションをお読みください。その後で、関連付けに関するさまざまなヒントや活用方法、Railsの関連付けメソッドとオプションの完全な参考情報も紹介します。

関連付けの種類
-------------------------

Railsでサポートされている関連付けは以下の6種類です。

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

関連付けは、一種のマクロ的な呼び出しとして実装されており、これによってモデル間の関連付けを宣言的に追加できます。たとえば、あるモデルが他のモデルに従属している(`belongs_to`)と宣言すると、2つのモデルのそれぞれのインスタンス間で「[主キー](https://ja.wikipedia.org/wiki/%E4%B8%BB%E3%82%AD%E3%83%BC) - [外部キー](https://ja.wikipedia.org/wiki/%E5%A4%96%E9%83%A8%E3%82%AD%E3%83%BC)」情報を保持しておくようにRailsに指示します。同時に、いくつかの便利なメソッドもそのモデルに追加されます。

本ガイドではこの後、それぞれの関連付けの宣言方法と利用方法について詳しく解説します。その前に、それぞれの関連付けが適切となる状況について簡単にご紹介します。

[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
