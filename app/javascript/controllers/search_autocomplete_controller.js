import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "results"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.selectedIndex = -1
  }

  search(event) {
    const query = event.target.value.trim()
    
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    if (query.length < 2) {
      this.hideDropdown()
      return
    }

    this.timeout = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 300)
  }

  async fetchSuggestions(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      const suggestions = await response.json()
      
      if (suggestions.length > 0) {
        this.renderSuggestions(suggestions)
        this.showDropdown()
      } else {
        this.hideDropdown()
      }
    } catch (error) {
      console.error('Error fetching suggestions:', error)
      this.hideDropdown()
    }
  }

  renderSuggestions(suggestions) {
    const html = suggestions.map((suggestion, index) => {
      const icon = suggestion.type === 'document' ? 'document-text' : 'folder'
      return `
        <div class="px-4 py-2 hover:bg-slate-50 dark:hover:bg-slate-700 cursor-pointer flex items-center gap-2 suggestion-item" 
             data-index="${index}" 
             data-text="${suggestion.text}">
          <svg class="size-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            ${this.getIconPath(icon)}
          </svg>
          <span class="text-sm text-slate-900 dark:text-slate-100">${suggestion.text}</span>
          <span class="text-xs text-slate-500 dark:text-slate-400 ml-auto">${suggestion.type}</span>
        </div>
      `
    }).join('')
    
    this.resultsTarget.innerHTML = html
    
    // Add click listeners
    this.resultsTarget.querySelectorAll('.suggestion-item').forEach(item => {
      item.addEventListener('click', (e) => {
        const text = e.currentTarget.dataset.text
        this.selectSuggestion(text)
      })
    })
  }

  getIconPath(iconName) {
    const icons = {
      'document-text': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>',
      'folder': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>'
    }
    return icons[iconName] || icons['document-text']
  }

  selectSuggestion(text) {
    this.element.querySelector('input[name="q"]').value = text
    this.hideDropdown()
    // Optionally trigger search immediately
    this.element.querySelector('form').submit()
  }

  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
    this.selectedIndex = -1
  }

  // Handle keyboard navigation
  keydown(event) {
    const items = this.resultsTarget.querySelectorAll('.suggestion-item')
    
    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.highlightItem(items)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.highlightItem(items)
        break
      case 'Enter':
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          event.preventDefault()
          const text = items[this.selectedIndex].dataset.text
          this.selectSuggestion(text)
        }
        break
      case 'Escape':
        this.hideDropdown()
        break
    }
  }

  highlightItem(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-slate-50', 'dark:bg-slate-700')
      } else {
        item.classList.remove('bg-slate-50', 'dark:bg-slate-700')
      }
    })
  }

  // Hide dropdown when clicking outside
  disconnect() {
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }
}