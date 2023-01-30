# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "turbolinks", to: "https://ga.jspm.io/npm:turbolinks@5.2.0/dist/turbolinks.js"
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.0.4-1/app/assets/javascripts/activestorage.esm.js"
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/esm/popper.min.js", preload: true
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.2.3/dist/js/bootstrap.esm.min.js", preload: true
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "local-time", to: "https://ga.jspm.io/npm:local-time@2.1.0/app/assets/javascripts/local-time.js"
pin_all_from File.expand_path("../app/javascript", __dir__)
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.0.4-2/lib/assets/compiled/rails-ujs.js"
