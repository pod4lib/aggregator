# frozen_string_literal: true

# :nodoc:
class ApplicationMailer < ActionMailer::Base
  default from: Settings.action_mailer.default_options.from
  layout 'mailer'
end
