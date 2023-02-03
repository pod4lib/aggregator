// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from "@rails/activestorage";
import LocalTime from "local-time"
Rails.start();
Turbolinks.start();
ActiveStorage.start();
LocalTime.start()

// require('../channels');
import 'direct_uploads';
import 'pod_console';
import 'copy_to_clipboard';
import 'organizations';
import 'tooltips'