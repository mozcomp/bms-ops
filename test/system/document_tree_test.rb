require "application_system_test_case"

class DocumentTreeTest < ApplicationSystemTestCase
  def setup
    @user = users(:one)
    @user.update!(admin: true)
    
    # Create test folder structure
    @root_folder = Folder.create!(name: "Root Folder", created_by: @user)
    @subfolder = Folder.create!(name: "Subfolder", parent: @root_folder, created_by: @user)
    
    # Create test documents
    @root_document = Document.create!(
      title: "Root Document",
      content: "Root content",
      published: true,
      visibility: "public",
      created_by: @user,
      updated_by: @user
    )
    
    @folder_document = Document.create!(
      title: "Folder Document",
      content: "Folder content",
      folder: @root_folder,
      published: true,
      visibility: "public",
      created_by: @user,
      updated_by: @user
    )
  end

  test "visiting the documents index shows tree view" do
    visit documents_path
    
    # Should show the tree sidebar
    assert_selector ".document-tree"
    
    # Should show root folder
    assert_text "Root Folder"
    
    # Should show root document
    assert_text "Root Document"
  end

  test "tree view shows folder structure" do
    visit documents_path
    
    # Should show folders with folder icons
    within ".document-tree" do
      assert_selector ".folder-item", text: "Root Folder"
      
      # Folder should be collapsed initially (children hidden)
      assert_selector ".folder-children[style*='display: none']"
    end
  end

  test "tree view shows documents with document icons" do
    visit documents_path
    
    within ".document-tree" do
      # Should show root level document
      assert_selector ".file-item", text: "Root Document"
      
      # Should have document icon
      assert_selector ".file-item svg"
    end
  end

  test "admin users see add buttons" do
    visit documents_path
    
    within ".document-tree" do
      # Should show add folder and add document buttons
      assert_selector "button[title='Add Folder']"
      assert_selector "button[title='Add Document']"
    end
  end

  test "clicking on document navigates to document page" do
    visit documents_path
    
    within ".document-tree" do
      click_on "Root Document"
    end
    
    # Should navigate to document show page
    assert_current_path document_path(@root_document)
    assert_text "Root Document"
  end

  private

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
  end
end