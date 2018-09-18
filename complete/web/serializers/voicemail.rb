require 'twilio-ruby'

module MariaCallCenter
  module Serializers
    class Voicemail

      def serialize(voicemail:)
        ::Twilio::TwiML::VoiceResponse.new do |r|
          r.say(message: voicemail.message) if voicemail.message
          r.record(action: 'hangup_call', method: 'POST', timeout: voicemail.timeout, playBeep: voicemail.beep)
          r.hangup
        end
      end
    end
  end
end
