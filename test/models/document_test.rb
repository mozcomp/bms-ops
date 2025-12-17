require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user.update!(admin: true)
    @folder = Folder.create!(name: "Test Folder", created_by: @user)
  end

  test "should create document with valid attributes" do
    document = Document.new(
      title: "Test Document",
      content: "Test content",
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    assert document.valid?
    assert document.save
  end

  test "should require title" do
    document = Document.new(
      content: "Test content",
      created_by: @user,
      updated_by: @user
    )
    
    assert_not document.valid?
    assert_includes document.errors[:title], "can't be blank"
  end

  test "should require content" do
    document = Document.new(
      title: "Test Document",
      created_by: @user,
      updated_by: @user
    )
    
    assert_not document.valid?
    assert_includes document.errors[:content], "can't be blank"
  end

  test "should generate slug from title" do
    document = Document.create!(
      title: "Test Document Title",
      content: "Test content",
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    assert_equal "test-document-title", document.slug
  end

  test "should ensure unique slug within folder" do
    Document.create!(
      title: "Test Document",
      content: "Test content",
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    document2 = Document.create!(
      title: "Test Document",
      content: "Test content 2",
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    assert_equal "test-document-1", document2.slug
  end

  test "should create version when content changes" do
    document = Document.create!(
      title: "Test Document",
      content: "Original content",
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    assert_equal 0, document.document_versions.count
    
    document.update!(content: "Updated content")
    
    assert_equal 1, document.document_versions.count
    assert_equal "Original content", document.document_versions.first.content
  end

  test "published scope should return only published documents" do
    published_doc = Document.create!(
      title: "Published Document",
      content: "Test content",
      published: true,
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    unpublished_doc = Document.create!(
      title: "Unpublished Document",
      content: "Test content",
      published: false,
      created_by: @user,
      updated_by: @user,
      folder: @folder
    )
    
    published_documents = Document.published
    
    assert_includes published_documents, published_doc
    assert_not_includes published_documents, unpublished_doc
  end
end