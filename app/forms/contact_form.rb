# frozen_string_literal: true

# send email via contact form
class ContactForm < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: /\A([\w.%+-]+)@([\w-]+\.)+(\w{2,})\z/i
  attribute :message
  attribute :reason

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: "Contact: #{reason}",
      to: 'info@bssw.io',
      from: %("BSSw Contact Form" <info@parallactic.com>)
    }
  end
end
