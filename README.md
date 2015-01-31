# TokenPagination

Provides page token based pagination for your active record

This module currently works together with rails > 4.1 and active record.
It allows as to use pointer based queries easily and securely which would benefit in both
performance wise and UI/UX wise for various cases compared to using OFFSET/LIMIT based queries.


## Features

### Optimized in performance
Offset limit pagination works great in lots of cases.
It has two characteristics

* Collection resource is generated every time you make a request (i.e by using query parameter)
* Items you wish to get is specified by, starting index and count

But using offset/limit based pagination on RDBS using B-Tree can cause serious performance problem
Examples below.
```
SELECT id FROM users LIMIT 1000000, 100
```

this gem paginates by selecting pointer items to paginate from, which greatly improves performance when used with Index.
```
SELECT id FROM users WHERE id > 1000000 LIMIT 100
```


### Easy
You can use any active record method to filter result_set and just call page_by_token.
i.e
```
@books = user.books.where(
                      :published => true
                    ).where(
                      "id > 100"
                    ).order(
                      :id => :desc
                    ).page_by_token(
                      count,
                      params[:page_token]
                    )

# Return jwt in string, if there is no more items to be fetched, returns nil
@next_page_token = @books.next_page_token
```
page_token is an JSON Web Token encoding following informations

* Definition of collection (In this case, active_record relation object information)
* Pointer instance specifying next item

It embedds architecture behind the pagination to single token, so we can simplify pagination queries, and make very api friendly interface as in following example.

```
# FIRST PAGE
GET /items?category_id=1

{
  entry: [ ... correction goes here ],
  next_page_token: "PAGE_TOKEN_"
}

# SECOND PAGE
GET /items?category_id=1&page_token=NEXT_PAGE_TOKEN_IN_PREVIOUS_REQUEST

{
  entry: [ ... correction of second page goes here ],
  next_page_token: "PAGE_TOKEN"
}
```


## UI/UX Friendly

In some cases, offset limit pagination is unfriendly UI/UX wise.
These cases are when
* Items are rapidly pushed to top of the collection
* Items once pushed rarely moves its location

Twitter timeline is one good example of such a collection. When you have these kind of collection, and paginate with offset/limit,
pagination would likely have a problem as in following situation

* Query first page with offset 0 limit 100
* 10 more items are pushed
* Query next page with offset 100 limit 100
* 10 items are duplicated

These problems can be fixed by using pointer based pagination because, you specify items to query next page from.
Any items pushed to top of the list will not affect the result of next page.

### Secure
Secure, it uses JSON Web Token to be secure for malicious use of query parameter from users
```
@books = User.order(id::desc).page_by_token(10,"ILLEGAL_PAGE_TOKEN") # []
@books = User.order(id::desc).page_by_token!(10,"ILLEGAL_PAGE_TOKEN") # raise error

@books = User.order(id::desc).page_by_token(10,"PAGE_TOKEN_FROM_OTHER_RELATION") # []
@books = User.order(id::desc).page_by_token!(10,"PAGE_TOKEN_FROM_OTHRE_RELATION") # raise error
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'token_pagination'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install token_pagination

## Usage


### Iterating basic collections

Getting pages are very easily implemtend,  Following is an example(asuming user with 15 posts)

```
@posts = @user.posts.where(published:true).order(:id  => :desc).page_by_token(10)
# SELECT * FROM posts WHERE published = 1 AND user_id = ? ORDER BY id  DESC LIMT 10

# Get next page
next_page_token = @posts.next_page_token # this would be a of jwt
@posts = @user.posts.where(published: true).order(:id => :desc).page_by_token(10, next_page_token)
# SELECT * FROM posts WHERE published=1 AND user_id = ? AND id < ? LIMIT 10

next_page_token = @posts.next_page_token # nil

```

### Ordering with multiple columns would  work too
```
@posts = @user.posts.order(:rating  => :desc).order(:id => :desc).page_by_token(10)
# SELECT * FROM posts
# WHERE user_id = ?
# ORDER BY rating desc, created_at  DESC LIMT 10

@posts = @user.posts.order(:rating  => :desc).order(:id => :desc).page_by_token(10, @posts.page_token)
# SELECT * FROM posts
# WHERE     user_id = ?
#       AND rating <= ?
#       AND (rating < ? OR (rating = ? AND id < ?)
# ORDER BY rating desc, created_at  DESC LIMT 10

```



## Contributing

1. Fork it ( https://github.com/[my-github-username]/token_pagination/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
