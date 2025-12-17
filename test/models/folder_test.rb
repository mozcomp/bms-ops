require "test_helper"

class FolderTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user.update!(admin: true)
  end

  test "should create folder with valid attributes" do
    folder = Folder.new(
      name: "Test Folder",
      created_by: @user
    )
    
    assert folder.valid?
    assert folder.save
  end

  test "should require name" do
    folder = Folder.new(created_by: @user)
    
    assert_not folder.valid?
    assert_includes folder.errors[:name], "can't be blank"
  end

  test "should generate slug from name" do
    folder = Folder.create!(
      name: "Test Folder Name",
      created_by: @user
    )
    
    assert_equal "test-folder-name", folder.slug
  end

  test "should ensure unique slug within parent" do
    parent = Folder.create!(name: "Parent", created_by: @user)
    
    Folder.create!(
      name: "Test Folder",
      parent: parent,
      created_by: @user
    )
    
    folder2 = Folder.create!(
      name: "Test Folder",
      parent: parent,
      created_by: @user
    )
    
    assert_equal "test-folder-1", folder2.slug
  end

  test "should prevent circular references" do
    parent = Folder.create!(name: "Parent", created_by: @user)
    child = Folder.create!(name: "Child", parent: parent, created_by: @user)
    
    parent.parent = child
    
    assert_not parent.valid?
    assert_includes parent.errors[:parent], "cannot be a descendant of this folder"
  end

  test "should prevent self-reference" do
    folder = Folder.create!(name: "Test", created_by: @user)
    folder.parent = folder
    
    assert_not folder.valid?
    assert_includes folder.errors[:parent], "cannot be the same as the folder itself"
  end

  test "should return correct path" do
    grandparent = Folder.create!(name: "Grandparent", created_by: @user)
    parent = Folder.create!(name: "Parent", parent: grandparent, created_by: @user)
    child = Folder.create!(name: "Child", parent: parent, created_by: @user)
    
    assert_equal ["Grandparent", "Parent", "Child"], child.path
    assert_equal "Grandparent / Parent / Child", child.full_path
  end

  test "should identify root folders" do
    root = Folder.create!(name: "Root", created_by: @user)
    child = Folder.create!(name: "Child", parent: root, created_by: @user)
    
    assert root.root?
    assert_not child.root?
  end

  test "should identify leaf folders" do
    parent = Folder.create!(name: "Parent", created_by: @user)
    child = Folder.create!(name: "Child", parent: parent, created_by: @user)
    
    assert child.leaf?
    assert_not parent.leaf?
  end

  test "root_folders scope should return only root folders" do
    root1 = Folder.create!(name: "Root 1", created_by: @user)
    root2 = Folder.create!(name: "Root 2", created_by: @user)
    child = Folder.create!(name: "Child", parent: root1, created_by: @user)
    
    root_folders = Folder.root_folders
    
    assert_includes root_folders, root1
    assert_includes root_folders, root2
    assert_not_includes root_folders, child
  end
end