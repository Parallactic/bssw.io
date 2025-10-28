# frozen_string_literal: true

# send email via contact form
class Contribute < ContactForm
  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {      subject: "Contribute: #{reason}",
           to: 'info@bssw.io',
           from: %("BSSw Contribution Form" <info@parallactic.com>) }
  end
end
