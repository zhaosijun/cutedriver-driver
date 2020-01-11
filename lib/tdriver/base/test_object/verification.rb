
module TDriver

  module TestObjectVerification

    # private variables and methods  
    class << self
    
      # TODO: Document me (TestObjectFactory::check_verify_always_reporting_settings)
      def check_verify_always_reporting_settings

        @@reporter_attached = $parameters[ :report_attach_continuous_verification_to_reporter, 'false' ]

        @@rcv_raise_errors = $parameters[ :report_continuous_verification_raise_errors, 'true' ]

        @@rcv_fail_test_case = $parameters[ :report_continuous_verification_fail_test_case_on_error, 'true' ]

        @@rvc_capture_screen = $parameters[ :report_continuous_verification_capture_screen_on_error, 'true' ]

      end

      # TODO: Document me (TestObjectFactory::restore_verify_always_reporting_settings)
      def restore_global_verify_always_reporting_settings

        @@reporter_attached = @@global_reporter_attached

        @@rcv_raise_errors = @@rcv_global_raise_errors

        @@rcv_fail_test_case = @@rcv_global_fail_test_case

        @@rvc_capture_screen = @@rvc_global_capture_screen

      end

      def initialize_settings

        # defaults
        @@global_reporter_attached = $parameters[ :report_attach_continuous_verification_to_reporter, 'false' ]

        @@rcv_global_raise_errors = $parameters[ :report_continuous_verification_raise_errors, 'true' ]

        @@rcv_global_fail_test_case = $parameters[ :report_continuous_verification_fail_test_case_on_error, 'true' ]

        @@rvc_global_capture_screen = $parameters[ :report_continuous_verification_capture_screen_on_error, 'true' ]

        @@inside_verify = false

        @@initialized = true

      end

      # defaults
      @@initialized = false
                    
    end
      
    def self.verify_ui_dump( sut )

      initialize_settings unless @@initialized

      return if @@inside_verify

      begin

        @@inside_verify = true

        logging_enabled = $logger.enabled

        sut.verify_blocks.each do | verify |

          check_verify_always_reporting_settings()

          begin

            $logger.enabled = false

            begin
            
              result = verify.block.call( sut )

            rescue Exception => e

              if @@rcv_raise_errors == 'true' || @@reporter_attached == 'false'

                raise MobyBase::ContinuousVerificationError.new(
                  "Verification failed as an exception was thrown when the verification block was executed. #{ verify.source }\nDetails: #{ ( verify.message || "none" ) }\nNested exception:\n#{ e.inspect }"
                )
                
              elsif @@reporter_attached == 'true' && @@rcv_raise_errors == 'false'

                TDriverReportAPI::tdriver_report_set_test_case_status('failed') if @@rcv_fail_test_case == 'true'

                if @@rvc_capture_screen == 'true'

                  TDriverReportAPI::tdriver_capture_state

                else

                  TDriverReportAPI::tdriver_capture_state( false )
                  
                end

                TDriverReportAPI::tdriver_report_log("Verification failed as an exception was thrown when the verification block was executed. #{ verify.source }\nDetails: #{( verify.message || "none" ) }\nNested exception:\n#{ e.inspect }")

                TDriverReportAPI::tdriver_report_log("<hr />")
                
                $logger.enabled = logging_enabled
                $logger.behaviour "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s

              end

            end

            unless result == verify.expected

              if @@rcv_raise_errors == 'true' || @@reporter_attached == 'false'
              
                raise MobyBase::ContinuousVerificationError.new(
                  "Verification failed. #{ verify.source }\nDetails: #{ ( verify.message || "none" ) }\nThe block did not return #{ verify.expected.inspect }. It returned: #{ result.inspect }"
                )
                
              elsif @@reporter_attached == 'true' && @@rcv_raise_errors == 'false'
              
                TDriverReportAPI::tdriver_report_set_test_case_status('failed') if @@rcv_fail_test_case == 'true'
                
                if @@rvc_capture_screen == 'true'

                  TDriverReportAPI::tdriver_capture_state

                else

                  TDriverReportAPI::tdriver_capture_state( false )

                end
                
                TDriverReportAPI::tdriver_report_log(
                  "Verification failed. #{ verify.source }\nDetails: #{ ( verify.message || "none" ) }\nThe block did not return #{ verify.expected.inspect }. It returned: #{ result.inspect } "
                )
                
                TDriverReportAPI::tdriver_report_log("<hr />")

                $logger.enabled = logging_enabled
                
                $logger.behaviour "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s

              end
            
            end

          rescue Exception => e

            $logger.enabled = logging_enabled

            $logger.behaviour "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s

            @@inside_verify = false

            raise e
          
          end

          # Do NOT report PASS cases, like other verify blocks do. This would clog the log with useless info.
          restore_global_verify_always_reporting_settings
        
        end

      ensure

        $logger.enabled = logging_enabled
        @@inside_verify = false      

      end
      
    end # verify_ui
      
  end # TestObjectVerification

end # TDriver
