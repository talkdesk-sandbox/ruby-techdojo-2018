require 'twilio-ruby'

module MariaCallCenter
  module Serializers
    class Hangup

      def serialize(hangup_call:)
        Twilio::TwiML::VoiceResponse.new.hangup
      end
    end
  end
end
