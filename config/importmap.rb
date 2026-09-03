# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "@garmin/fitsdk", to: "@garmin--fitsdk.js" # @21.213.0
pin "mapbox-gl" # @3.28.1
pin "@splidejs/splide", to: "@splidejs--splide.js" # @4.1.4
pin "@splidejs/splide-extension-grid", to: "@splidejs--splide-extension-grid.js" # @0.4.1
