import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="document-tree"
export default class extends Controller {
  static targets = ["folder", "file", "content"]
  static values = { 
    selectedFile: String,
    expandedFolders: Array
  }

  connect() {
    // Load expanded state from localStorage
    const saved = localStorage.getItem('documentTreeExpanded')
    if (saved) {
      this.expandedFoldersValue = JSON.parse(saved)
    }
    
    // Apply saved expanded state
    this.applyExpandedState()
    
    // Highlight selected file if any
    if (this.selectedFileValue) {
      this.highlightSelectedFile(this.selectedFileValue)
    }
  }

  // Toggle folder expand/collapse
  toggleFolder(event) {
    event.preventDefault()
    const folder = event.currentTarget.closest('[data-folder-id]')
    const folderId = folder.dataset.folderId
    const isExpanded = folder.classList.contains('expanded')
    
    if (isExpanded) {
      this.collapseFolder(folder, folderId)
    } else {
      this.expandFolder(folder, folderId)
    }
    
    this.saveExpandedState()
  }

  // Expand a folder
  expandFolder(folder, folderId) {
    folder.classList.add('expanded')
    const children = folder.querySelector('.folder-children')
    const icon = folder.querySelector('.folder-icon')
    
    if (children) {
      children.style.display = 'block'
    }
    
    if (icon) {
      icon.textContent = '−' // Minus sign for expanded
    }
    
    // Add to expanded folders array
    if (!this.expandedFoldersValue.includes(folderId)) {
      this.expandedFoldersValue = [...this.expandedFoldersValue, folderId]
    }
  }

  // Collapse a folder
  collapseFolder(folder, folderId) {
    folder.classList.remove('expanded')
    const children = folder.querySelector('.folder-children')
    const icon = folder.querySelector('.folder-icon')
    
    if (children) {
      children.style.display = 'none'
    }
    
    if (icon) {
      icon.textContent = '+' // Plus sign for collapsed
    }
    
    // Remove from expanded folders array
    this.expandedFoldersValue = this.expandedFoldersValue.filter(id => id !== folderId)
  }

  // Select a file
  selectFile(event) {
    event.preventDefault()
    const fileElement = event.currentTarget
    const fileId = fileElement.dataset.fileId
    const fileUrl = fileElement.dataset.fileUrl
    
    // Remove previous selection
    this.element.querySelectorAll('.file-item.selected').forEach(item => {
      item.classList.remove('selected')
    })
    
    // Add selection to clicked file
    fileElement.classList.add('selected')
    this.selectedFileValue = fileId
    
    // Navigate to the file or load content
    if (fileUrl) {
      window.location.href = fileUrl
    }
  }

  // Add new folder
  addFolder(event) {
    event.preventDefault()
    const button = event.currentTarget
    const parentId = button.dataset.parentId || ''
    
    // Create form for new folder name
    const folderName = prompt('Enter folder name:')
    if (!folderName) return
    
    // Submit form to create folder
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = parentId ? `/folders/${parentId}/folders` : '/folders'
    
    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }
    
    // Add folder name
    const nameInput = document.createElement('input')
    nameInput.type = 'hidden'
    nameInput.name = 'folder[name]'
    nameInput.value = folderName
    form.appendChild(nameInput)
    
    // Add parent_id if needed (for nested routes)
    if (parentId) {
      // The nested route expects parent_id in the URL, not as a parameter
      // But we still need to set the parent relationship
      const parentInput = document.createElement('input')
      parentInput.type = 'hidden'
      parentInput.name = 'parent_id'
      parentInput.value = parentId
      form.appendChild(parentInput)
    }
    
    document.body.appendChild(form)
    form.submit()
  }

  // Add new file
  addFile(event) {
    event.preventDefault()
    const button = event.currentTarget
    const folderId = button.dataset.folderId || ''
    
    // Navigate to new document form
    const url = folderId ? `/folders/${folderId}/documents/new` : '/documents/new'
    window.location.href = url
  }

  // Apply expanded state from saved data
  applyExpandedState() {
    this.expandedFoldersValue.forEach(folderId => {
      const folder = this.element.querySelector(`[data-folder-id="${folderId}"]`)
      if (folder) {
        this.expandFolder(folder, folderId)
      }
    })
  }

  // Save expanded state to localStorage
  saveExpandedState() {
    localStorage.setItem('documentTreeExpanded', JSON.stringify(this.expandedFoldersValue))
  }

  // Highlight selected file
  highlightSelectedFile(fileId) {
    const fileElement = this.element.querySelector(`[data-file-id="${fileId}"]`)
    if (fileElement) {
      fileElement.classList.add('selected')
    }
  }

  // Handle keyboard navigation
  keydown(event) {
    const focused = document.activeElement
    
    switch(event.key) {
      case 'ArrowUp':
        event.preventDefault()
        this.focusPrevious(focused)
        break
      case 'ArrowDown':
        event.preventDefault()
        this.focusNext(focused)
        break
      case 'ArrowRight':
        if (focused.classList.contains('folder-item')) {
          event.preventDefault()
          const folderId = focused.dataset.folderId
          const folder = focused.closest('[data-folder-id]')
          if (!folder.classList.contains('expanded')) {
            this.expandFolder(folder, folderId)
            this.saveExpandedState()
          }
        }
        break
      case 'ArrowLeft':
        if (focused.classList.contains('folder-item')) {
          event.preventDefault()
          const folderId = focused.dataset.folderId
          const folder = focused.closest('[data-folder-id]')
          if (folder.classList.contains('expanded')) {
            this.collapseFolder(folder, folderId)
            this.saveExpandedState()
          }
        }
        break
      case 'Enter':
      case ' ':
        event.preventDefault()
        if (focused.classList.contains('folder-item')) {
          this.toggleFolder({ currentTarget: focused, preventDefault: () => {} })
        } else if (focused.classList.contains('file-item')) {
          this.selectFile({ currentTarget: focused, preventDefault: () => {} })
        }
        break
    }
  }

  // Focus previous item in tree
  focusPrevious(current) {
    const items = Array.from(this.element.querySelectorAll('.folder-item, .file-item'))
    const currentIndex = items.indexOf(current)
    if (currentIndex > 0) {
      items[currentIndex - 1].focus()
    }
  }

  // Focus next item in tree
  focusNext(current) {
    const items = Array.from(this.element.querySelectorAll('.folder-item, .file-item'))
    const currentIndex = items.indexOf(current)
    if (currentIndex < items.length - 1) {
      items[currentIndex + 1].focus()
    }
  }
}