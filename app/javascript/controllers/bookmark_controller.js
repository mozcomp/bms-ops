import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    documentId: Number, 
    bookmarked: Boolean, 
    url: String 
  }

  connect() {
    this.updateUI()
  }

  async toggle() {
    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.bookmarkedValue = data.bookmarked
        this.updateUI()
        
        // Show a brief success message
        this.showMessage(data.message)
      } else {
        throw new Error('Failed to toggle bookmark')
      }
    } catch (error) {
      console.error('Error toggling bookmark:', error)
      this.showMessage('Failed to update bookmark', 'error')
    }
  }

  updateUI() {
    const icon = this.element.querySelector('.bookmark-icon')
    const text = this.element.querySelector('.bookmark-text')
    
    if (this.bookmarkedValue) {
      icon.classList.add('text-yellow-500')
      text.textContent = 'Bookmarked'
    } else {
      icon.classList.remove('text-yellow-500')
      text.textContent = 'Bookmark'
    }
  }

  showMessage(message, type = 'success') {
    // Create a temporary flash message
    const flashContainer = document.querySelector('.flash-messages') || document.body
    const flashElement = document.createElement('div')
    
    const bgColor = type === 'error' ? 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800' : 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800'
    const textColor = type === 'error' ? 'text-red-800 dark:text-red-400' : 'text-green-800 dark:text-green-400'
    
    flashElement.className = `fixed top-4 right-4 z-50 ${bgColor} border rounded-lg p-4 shadow-lg transition-all duration-300 transform translate-x-full`
    flashElement.innerHTML = `
      <div class="flex items-center gap-3">
        <div class="${textColor}">
          ${message}
        </div>
        <button type="button" class="text-slate-400 hover:text-slate-600" onclick="this.parentElement.parentElement.remove()">
          <svg class="size-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `
    
    flashContainer.appendChild(flashElement)
    
    // Animate in
    setTimeout(() => {
      flashElement.classList.remove('translate-x-full')
    }, 100)
    
    // Auto remove after 3 seconds
    setTimeout(() => {
      flashElement.classList.add('translate-x-full')
      setTimeout(() => {
        flashElement.remove()
      }, 300)
    }, 3000)
  }
}