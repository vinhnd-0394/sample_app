import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['textarea'];

  connect() {
    this.resizeHeight();
    this.textareaTarget.addEventListener('input', () => this.resizeHeight());
  }

  resizeHeight() {
    if (this.textareaTarget) {
      this.textareaTarget.style.height = 'auto';
      const newHeight = Math.min(
        this.textareaTarget.scrollHeight,
        this.maxHeight()
      );
      this.textareaTarget.style.height = `${newHeight}px`;
      if (newHeight === this.maxHeight()) {
        this.textareaTarget.style.overflowY = 'auto';
      }
    }
  }

  maxHeight() {
    const computedStyle = window.getComputedStyle(this.textareaTarget);
    return parseFloat(computedStyle.maxHeight);
  }

  get textareaTarget() {
    return this.targets.find('textarea');
  }
}
