require 'maria_call_center/log'
require 'maria_call_center/models/hangup'

module MariaCallCenter
  module Interactors
    class HangupCall
      include Log

      def initialize(_environment)
      end

      def call
        Models::Hangup.new()
      end
    end
  end
end
