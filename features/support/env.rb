require "cucumber/rails"
require "devise"

World(FactoryBot::Syntax::Methods)
World(Warden::Test::Helpers)
Warden.test_mode!
After do
  Warden.test_reset!
end

DatabaseCleaner.strategy = :truncation
Around do |_scenario, block|
  DatabaseCleaner.cleaning(&block)
end

Capybara.default_selector = :css
Capybara.default_max_wait_time = 5
