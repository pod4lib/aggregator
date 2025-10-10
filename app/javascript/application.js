// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as ActiveStorage from "@rails/activestorage";
import LocalTime from "local-time"
ActiveStorage.start();
LocalTime.start()

// require('../channels');
import 'direct_uploads';
import 'organizations';
import 'popovers'
import "@hotwired/turbo-rails"
import "controllers"
