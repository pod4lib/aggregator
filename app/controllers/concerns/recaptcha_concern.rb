# frozen_string_literal: true

# Validate recaptcha challenge responses
module RecaptchaConcern
  def verify_recaptcha?(token, action: nil, minimum_score: 0.5, secret_key: Settings.recaptcha.secret_key)
    return true unless secret_key

    response = HTTP.get("https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{token}")
    Rails.logger.info('CAPTCHA response')
    Rails.logger.info(response.body)
    json = JSON.parse(response.body)
    json['success'] && json['score'] > minimum_score && json['action'] == action
  end
end
