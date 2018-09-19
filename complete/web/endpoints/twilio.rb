require 'grape'
require 'serializers/say'
require 'serializers/menu'
require 'serializers/input'
require 'serializers/goto'
require 'serializers/voicemail'
require 'serializers/dial'
require 'serializers/hangup'

module MariaCallCenter
  module Endpoints
    class Twilio < Grape::API
      resource :inbound_call do
        post do
          say = System[:play_greeting].call

          status 200

          serializer = MariaCallCenter::Serializers::Say.new
          serializer.serialize(say: say, next_step: :main_menu)
        end
      end

      resource :main_menu do
        post do
          menu = System[:present_main_menu].call

          status 200

          serializer = MariaCallCenter::Serializers::Menu.new
          serializer.serialize(menu: menu, success_handler: :main_menu_result, timeout_handler: :main_menu)
        end
      end

      resource :main_menu_result do
        params do
          requires :Digits, type: String, desc: 'Selected option', allow_blank: false
        end

        post do
          status 200

          serializer = MariaCallCenter::Serializers::Goto.new

          case params['Digits']
          when '1'
            serializer.serialize(next_step: :sub_menu)
          when '2'
            serializer.serialize(next_step: :dial_number)
          else
            serializer.serialize(next_step: :main_menu)
          end
        end
      end

      resource :sub_menu do
        post do
          menu = System[:present_sub_menu].call

          status 200

          serializer = MariaCallCenter::Serializers::Menu.new
          serializer.serialize(menu: menu, success_handler: :sub_menu_result)
        end
      end

      resource :sub_menu_result do
        params do
          requires :Digits, type: String, desc: 'Selected option', allow_blank: false
        end

        post do
          status 200

          serializer = MariaCallCenter::Serializers::Goto.new

          case params['Digits']
          when '1'
            serializer.serialize(next_step: :request_tax_number)
          when '2'
            serializer.serialize(next_step: :orders_message)
          else
            serializer.serialize(next_step: :voicemail)
          end
        end
      end

      resource :request_tax_number do
        post do
          input = System[:request_tax_number].call

          status 200

          serializer = MariaCallCenter::Serializers::Input.new
          serializer.serialize(input: input, success_handler: :payments_message, timeout_handler: :request_tax_number)
        end
      end

      resource :orders_message do
        post do
          say = System[:play_orders_message].call

          status 200

          serializer = MariaCallCenter::Serializers::Say.new
          serializer.serialize(say: say)
        end
      end

      resource :payments_message do
        params do
          requires :Digits, type: String, desc: 'Tax number', allow_blank: false
        end

        post do
          say = System[:play_payments_message].call(tax_number: params['Digits'])

          status 200

          serializer = MariaCallCenter::Serializers::Say.new
          serializer.serialize(say: say)
        end
      end

      resource :voicemail do
        post do
          voicemail = System[:leave_message].call(beep: true)

          status 200

          serializer = MariaCallCenter::Serializers::Voicemail.new
          serializer.serialize(voicemail: voicemail, next_step: :hangup_call)
        end
      end

      resource :dial_number do
        post do
          dial = System[:dial_external_number].call
          status 200

          serializer = MariaCallCenter::Serializers::Dial.new
          serializer.serialize(dial: dial)
        end
      end
      resource :hangup_call do
        post do
          status 200

          hangup_call = System[:hangup_call].call
          MariaCallCenter::Serializers::Hangup.new.serialize(hangup_call: hangup_call)
          
        end
      end
      
    end
  end
end
