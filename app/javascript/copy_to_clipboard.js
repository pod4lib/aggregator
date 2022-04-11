window.addEventListener('load', function() {
  if (document.querySelector('.custom-copy-button')) {
    document.querySelector('.custom-copy-button').addEventListener('click', async event => {
        if (!navigator.clipboard) {
          // Clipboard API not available
          return
        }
        const text = document.querySelector('.custom-copy-text').value
        try {
          await navigator.clipboard.writeText(text)
          event.target.textContent = 'Copied!'
        } catch (err) {
          console.error('Failed to copy!', err)
        }
      })
    }
});
