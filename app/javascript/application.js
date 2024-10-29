// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as ActiveStorage from "@rails/activestorage";
import LocalTime from "local-time"
ActiveStorage.start();
LocalTime.start()

// require('../channels');
import 'direct_uploads';
import 'pod_console';
import 'copy_to_clipboard';
import 'organizations';
import 'tooltips'
import "@hotwired/turbo-rails"
