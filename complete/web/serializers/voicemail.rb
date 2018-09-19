require 'twilio-ruby'

module MariaCallCenter
  module Serializers
    class Voicemail

      def serialize(voicemail:, next_step:)
        ::Twilio::TwiML::VoiceResponse.new do |r|
          r.say(message: voicemail.message) if voicemail.message
          r.record(action: next_step.to_s, timeout: voicemail.timeout, playBeep: voicemail.beep)
          r.hangup
        end
      end
    end
  end
end
