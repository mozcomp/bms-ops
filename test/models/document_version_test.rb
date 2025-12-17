require "test_helper"

class DocumentVersionTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user.update!(admin: true)
    @folder = Folder.create!(name: "Test Folder", created_by: @user)
    @document = Document.create!(
      title: "Test Document",
      content: "Original content",
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
  end

  test "should create document version with valid attributes" do
    version = DocumentVersion.new(
      document: @document,
      content: "Version content",
      version_number: 1,
      created_by: @user
    )
    
    assert version.valid?
    assert version.save
  end

  test "should require content" do
    version = DocumentVersion.new(
      document: @document,
      version_number: 1,
      created_by: @user
    )
    
    assert_not version.valid?
    assert_includes version.errors[:content], "can't be blank"
  end

  test "should require version number" do
    version = DocumentVersion.new(
      document: @document,
      content: "Version content",
      created_by: @user
    )
    
    assert_not version.valid?
    assert_includes version.errors[:version_number], "can't be blank"
  end

  test "should ensure unique version number per document" do
    DocumentVersion.create!(
      document: @document,
      content: "Version 1",
      version_number: 1,
      created_by: @user
    )
    
    version2 = DocumentVersion.new(
      document: @document,
      content: "Version 2",
      version_number: 1,
      created_by: @user
    )
    
    assert_not version2.valid?
    assert_includes version2.errors[:version_number], "has already been taken"
  end

  test "should find previous and next versions" do
    version1 = DocumentVersion.create!(
      document: @document,
      content: "Version 1",
      version_number: 1,
      created_by: @user
    )
    
    version2 = DocumentVersion.create!(
      document: @document,
      content: "Version 2",
      version_number: 2,
      created_by: @user
    )
    
    version3 = DocumentVersion.create!(
      document: @document,
      content: "Version 3",
      version_number: 3,
      created_by: @user
    )
    
    assert_equal version1, version2.previous_version
    assert_equal version3, version2.next_version
    assert_nil version1.previous_version
    assert_nil version3.next_version
  end

  test "should identify latest version" do
    version1 = DocumentVersion.create!(
      document: @document,
      content: "Version 1",
      version_number: 1,
      created_by: @user
    )
    
    version2 = DocumentVersion.create!(
      document: @document,
      content: "Version 2",
      version_number: 2,
      created_by: @user
    )
    
    assert_not version1.is_latest?
    assert version2.is_latest?
  end

  test "should return author name" do
    @user.update!(first_name: "John", last_name: "Doe")
    
    version = DocumentVersion.create!(
      document: @document,
      content: "Version content",
      version_number: 1,
      created_by: @user
    )
    
    assert_equal "John", version.author_name
  end
end