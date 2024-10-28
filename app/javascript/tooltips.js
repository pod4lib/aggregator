import * as bootstrap from 'bootstrap';

// Enable bootstrap tooltips, with localized time content if applicable
document.addEventListener('turbo:load', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        // Find any hidden time DOM elements within this tooltip
        var times = [].slice.call(tooltipTriggerEl.querySelectorAll('.hidden-tooltip-time[data-localized]'))
        var text = ""
        // Construct the tooltip text
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
        // Replace the title element of the tooltip
        tooltipTriggerEl.title = text
        return new bootstrap.Tooltip(tooltipTriggerEl)
    })

    // Allow the bootstrap HTML sanitizer to accept <time> element, which we use in our tooltips
    var myDefaultAllowList = bootstrap.Tooltip.Default.allowList
    myDefaultAllowList.time = []
});
