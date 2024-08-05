import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['profileDropdown'];

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this);
  }

  openDropdown() {
    const dropdown = this.profileDropdownTarget;
    const isHidden = dropdown.classList.toggle('hidden');
    if (!isHidden) {
      document.addEventListener('click', this.handleClickOutside);
    } else {
      document.removeEventListener('click', this.handleClickOutside);
    }
  }

  handleClickOutside(event) {
    const dropdown = this.profileDropdownTarget;
    if (
      !dropdown.classList.contains('hidden') &&
      !this.element.contains(event.target)
    ) {
      dropdown.classList.add('hidden');
      document.removeEventListener('click', this.handleClickOutside);
    }
  }
}
