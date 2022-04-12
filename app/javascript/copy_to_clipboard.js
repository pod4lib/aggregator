window.addEventListener('load', function() {
  if (!navigator.clipboard) {
    // Clipboard API not available
    return
  }

  // Get all the copy buttons on the page
  const copyButtons = document.querySelectorAll(".copy-token-button");

  copyButtons.forEach((copyButton) => {
    copyButton.addEventListener('click', async event => {
      // Match the buttons and their associated text by id
      // e.g. "copy-token-button-1" and "copy-token-text-1"
      const buttonId = copyButton.id
      const textId = buttonId.replace('copy-token-button', 'copy-token-text')
      const text = document.querySelector("#"+textId).value

      // Copy text to clipboard
      try {
        await navigator.clipboard.writeText(text)

        if (event.target instanceof SVGElement) {
          // We clicked the SVG inside the button
          event.target.closest('button').textContent = 'Copied!'
        } else {
          // We clicked the actual button
          event.target.textContent = 'Copied!'
        }
      } catch (err) {
        console.error('Failed to copy!', err)
      }
    })
  })

});
