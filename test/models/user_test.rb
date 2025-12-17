require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "admin? returns true for admin users" do
    user = User.new(admin: true)
    assert user.admin?
  end

  test "admin? returns false for non-admin users" do
    user = User.new(admin: false)
    assert_not user.admin?
  end

  test "full_name returns first and last name when both present" do
    user = User.new(first_name: "John", last_name: "Doe", email_address: "john@example.com")
    assert_equal "John Doe", user.full_name
  end

  test "full_name returns first name when only first name present" do
    user = User.new(first_name: "John", email_address: "john@example.com")
    assert_equal "John", user.full_name
  end

  test "full_name returns last name when only last name present" do
    user = User.new(last_name: "Doe", email_address: "john@example.com")
    assert_equal "Doe", user.full_name
  end

  test "full_name returns email when no names present" do
    user = User.new(email_address: "john@example.com")
    assert_equal "john@example.com", user.full_name
  end
end
