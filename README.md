# README

for dev: if you have docker, you can just simple click reopen in container

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    * ruby-4.0.1
    

* System dependencies

* Configuration

* Database creation

* Database initialization
    * In case of any new data, please run rails db:seed
    

* How to run the test suite
    - To run the cucumbers, "bundle exec cucumber"
    - To run a single cucumber test, "bundle exec cucumber features/#.feature"
    - To test stuff that is background job (such as mailing), run `bundle exec sidekiq` in a new terminal
    - RUN `apt-get update && apt-get install -y nano`, to get nano for `EDITOR=nano rails credentials:edit`

* Services (job queues, cache servers, search engines, etc.)


* Deployment instructions

## Work Division

| Feature Name        | Primary Developer | Secondary Developer | Notes                    |
|---------------------|-------------------|---------------------|--------------------------|
| Mock payment        | Eddison           | Cody                | Integrated Stripe API    |
| SendGrid            | Eddison           | Cody                | -                        |
| Daily Summary       | Bobby             | -                   | Use file extender        |

