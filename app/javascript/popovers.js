import * as bootstrap from 'bootstrap';

// Enable bootstrap popovers, with localized time content if applicable
document.addEventListener('turbo:load', function() {
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        // Find any hidden time DOM elements within this popover
        var times = [].slice.call(popoverTriggerEl.querySelectorAll('.hidden-popover-time[data-localized]'))
        var text = ""
        // Construct the popover text
        // See application_helper.js
        times.forEach(function (timeEl) {
            if (timeEl.classList.contains('default')) {
                text = text + ("Default since " + timeEl.innerHTML + "<br/>")
            }
            if (timeEl.classList.contains('start')) {
                text = text + (timeEl.innerHTML + " to ")
            }
            if (timeEl.classList.contains('end')) {
                text = text + (timeEl.innerHTML + "</br>")
            }
        })
        // Replace the title element of the popover
        popoverTriggerEl.dataset.bsContent = text
        return new bootstrap.Popover(popoverTriggerEl)
    })

    // Allow the bootstrap HTML sanitizer to accept <time> element, which we use in our popovers
    var myDefaultAllowList = bootstrap.Popover.Default.allowList
    myDefaultAllowList.time = []
});
