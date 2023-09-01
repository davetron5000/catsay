require "app"
require "capybara"
require "capybara/dsl"
require "redis"
require "dotenv"
RACK_ENV = ENV.fetch("RACK_ENV")
Dotenv.load(".env.#{RACK_ENV}", ".env.#{RACK_ENV}.local")
class TheOnlyTest < Minitest::Test
  include Capybara::DSL

  def setup
    Capybara.app = Sinatra::Application.new
    REDIS.del("messages")
  end

  def test_page
    REDIS.sadd("messages", "Message 1")
    REDIS.sadd("messages", "Message 2")
    visit "/"
    assert page.has_content?("CatSay")
    assert page.has_selector?(".dn[data-testid='stairs']")
    assert page.has_selector?(".dn[data-testid='piano']")
    assert page.has_content?("Message 1")
    assert page.has_content?("Message 2")
  end

  def test_form
    visit "/"
    fill_in "zoni-message", with: "Hello"
    fill_in "carlos-message", with:  "Hi, there!"
    select  "piano"
    click_on "Command My Cats!"
    assert page.has_content?("Hello")
    assert page.has_selector?(".dn[data-testid='stairs']")
    assert page.has_selector?(".db[data-testid='piano']")
    within ".db[data-testid='piano']" do
      assert page.has_content?("Hello")
      assert page.has_content?("Hi, there!")
    end
    assert page.has_selector?("input[value='Hello']")
    assert page.has_selector?("input[value='Hi, there!']")
  end

  def test_random
    REDIS.sadd("messages", "Message 1")
    REDIS.sadd("messages", "Message 2")
    visit "/"
    click_on "Show Random Image"

    stairs = page.has_selector?(".db[data-testid='stairs']")
    box    = page.has_selector?(".db[data-testid='box']")
    piano  = page.has_selector?(".db[data-testid='piano']")

    assert stairs || box || piano

    selector = if stairs
                 ".db[data-testid='stairs']"
               elsif box
                 ".db[data-testid='box']"
               elsif piano
                 ".db[data-testid='piano']"
               end
    within selector do
      assert page.has_content?("Message 1")
      assert page.has_content?("Message 2")
    end

  end

end
