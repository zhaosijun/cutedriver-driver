############################################################################
##
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
## All rights reserved.
## Contact: Nokia Corporation (testabilitydriver@nokia.com)
##
## This file is part of TDriver.
##
## If you have questions regarding the use of this file, please contact
## Nokia at testabilitydriver@nokia.com .
##
## This library is free software; you can redistribute it and/or
## modify it under the terms of the GNU Lesser General Public
## License version 2.1 as published by the Free Software Foundation
## and appearing in the file LICENSE.LGPL included in the packaging
## of this file.
##
############################################################################

module TDriverReportCreator

  #Test run class for new test run
  class TestRun < ReportCombine
    include TDriverReportWriter
    include ReportDataTable
    attr_accessor(
      :report_folder,
      :reporting_groups,
      :generic_reporting_groups,
      :start_time,
      :end_time,
      :run_time,
      :total_run,
      :total_passed,
      :total_failed,
      :total_not_run,
      :total_crash_files,
      :total_device_resets,
      :test_case_user_defined_status,
      :test_run_behaviour_log,
      :test_run_user_log,
      :test_case_user_data,
      :test_case_user_xml_data,
      :test_case_user_data_columns,
      :test_case_user_chronological_table_data,
      :attached_test_reports,
      :report_pages_ready,
      :memory_amount_start,
      :memory_amount_end,
      :memory_amount_total,
      :total_dump_count,
      :total_received_data,
      :total_sent_data,
      :result_storage_in_use,
      :pages,
      :duration_graph,
      :pass_statuses,
      :fail_statuses,
      :not_run_statuses,
      :report_editable,
      :test_fails,
      :report_exclude_passed_cases,
      :connection_errors
      
    )
    #class variables for summary report
    def initialize()
      @report_folder=nil
      @reporting_groups=nil
      @generic_reporting_groups=''
      @start_time=nil
      @end_time=nil
      @run_time=nil
      @total_run=0
      @total_passed=0
      @total_failed=0
      @total_not_run=0
      @total_crash_files=0
      @total_device_resets=0
      @connection_errors=0
      @test_case_user_defined_status=nil
      @test_run_behaviour_log = Array.new
      @test_run_user_log = Array.new
      @test_case_user_data=Array.new
      @test_case_user_data_columns = Array.new
      @test_case_user_chronological_table_data = Hash.new
      @test_case_user_xml_data = Hash.new
      @attached_test_reports = Array.new
      @report_pages_ready=Array.new
      @memory_amount_start='-'
      @memory_amount_end='-'
      @memory_amount_total='-'
      @total_dump_count=Hash.new
      @total_received_data=Hash.new
      @total_sent_data=Hash.new
      $result_storage_in_use=false
      @pages=$parameters[ :report_results_per_page, 50]
      @duration_graph=$parameters[ :report_generate_duration_graph, false]
      @pass_statuses=$parameters[ :report_passed_statuses, "passed" ].split('|')
      @fail_statuses=$parameters[ :report_failed_statuses, "failed" ].split('|')
      @not_run_statuses=$parameters[ :report_not_run_statuses, "not run" ].split('|')
      @report_editable=$parameters[ :report_editable, "false" ]
      @report_short_folders=$parameters[ :report_short_folders, 'false']
      @report_exclude_passed_cases=$parameters[ :report_exclude_passed_cases, 'false' ]
      @test_fails=Hash.new(0)  # return 0 by default if key not found


    end

	  def get_sequential_fails
      test_identifier = $new_test_case.test_case_group + "::" + $new_test_case.test_case_name
      return @test_fails[ test_identifier ]  # return 0 by default if key not found
	  end

    def update_sequential_fails( status )

      test_identifier = $new_test_case.test_case_group + "::" + $new_test_case.test_case_name

      if @pass_statuses.include?(status)
        @test_fails[ test_identifier ] = 0 unless @test_fails[ test_identifier ] == 0
      elsif @fail_statuses.include?(status)
        tempnum = @test_fails[ test_identifier ]
        tempnum = tempnum + 1
        @test_fails[ test_identifier ] = tempnum
      end


    end

    #This method sets the test case user defined status
    #
    # === params
    # value: test case status
    # === returns
    # nil
    # === raises
    def set_test_case_user_defined_status(value)
      @test_case_user_defined_status=value
    end
    #This method sets user created log
    #
    # === params
    # value: test run execution log entry
    # === returns
    # nil
    # === raises
    def set_log(value)
      if value==nil
        @test_run_user_log=nil
        @test_run_user_log=Array.new
      else
        @test_run_user_log << ["USER LOG: #{value.to_s}"]
      end
    end
    #This method adds user data
    #
    # === params
    # value: the data to be added an array or hash
    # === returns
    # nil
    # === raises
    # TypeError exception
    def set_user_data(value)
      if value==nil
        @test_case_user_data = Array.new
        @test_case_user_data_columns = Array.new
      else
        raise TypeError.new( 'Input parameter not of Type: Hash or Array.\nIt is: ' + value.class.to_s ) unless value.kind_of?( Hash ) || value.kind_of?( Array )
        if value.kind_of?( Hash )
          add_data_from_hash(value,@test_case_user_data,@test_case_user_data_columns)
        end
        if value.kind_of?( Array )
          add_data_from_array(value,@test_case_user_data,@test_case_user_data_columns)
        end
      end
    end
    #This method adds user table data
    #
    # === params
    # column_name: the column name in chronological table
    # value: the data
    # === returns
    # nil
    # === raises
    def set_user_table_data(column_name,value)
      if (!column_name.empty? && column_name!=nil)
        @test_case_user_chronological_table_data[column_name.to_s]=value.to_s
      end
    end
    
    #This method adds user xml data
    #
    # === params
    # column_name: the column name in xml
    # value: the data
    # === returns
    # nil
    # === raises
    def set_user_xml_data(column_name,value)
      if (!column_name.empty? && column_name!=nil)
        @test_case_user_xml_data[column_name.to_s]=value.to_s
      end
    end
    
    #This method sets the test run behaviour log
    #
    # === params
    # value: test run execution log entry
    # === returns
    # nil
    # === raises
    def set_test_run_behaviour_log(value,test_case)
      @test_run_behaviour_log << [value.to_s,test_case]
    end
    #This method sets generic reporting groups
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_generic_reporting_groups(value)
      if check_if_group_exists_groups(@generic_reporting_groups,value)==false
        @generic_reporting_groups=@generic_reporting_groups+value
      end
      get_reporting_groups()
    end
    #This method sets the report folder value
    #
    # === params
    # value: test set report folder
    # === returns
    # nil
    # === raises
    def set_report_folder(value)
      @report_folder=value
    end
    #This method sets the test run start time
    #
    # === params
    # value: test set start time
    # === returns
    # nil
    # === raises
    def set_start_time(value)
      @start_time=value
    end
    #This method sets the test run end time
    #
    # === params
    # value: test set end time
    # === returns
    # nil
    # === raises
    def set_end_time(value)
      @end_time=value
    end
    #This method sets the test run run time
    #
    # === params
    # value: test set run time
    # === returns
    # nil
    # === raises
    def set_run_time(value)
      @run_time=value
    end
    #This method sets the total tests run
    #
    # === params
    # value: total run value
    # === returns
    # nil
    # === raises
    def set_total_run(value)
      if value==1
        @total_run=@total_run.to_i+1
      else
        @total_run=value
      end
    end
    #This method sets the total passed tests run
    #
    # === params
    # value: total passed value
    # === returns
    # nil
    # === raises
    def set_total_passed(value)
      if value==1
        @total_passed=@total_passed.to_i+1
      else
        @total_passed=value
      end
    end
    #This method sets the total failed tests run
    #
    # === params
    # value: total failed value
    # === returns
    # nil
    # === raises
    def set_total_failed(value)
      if value==1
        @total_failed=@total_failed.to_i+1
      else
        @total_failed=value
      end
    end
    #This method sets the total amount of not run cases
    #
    # === params
    # value: total not run value
    # === returns
    # nil
    # === raises
    def set_total_not_run(value)
      if value==1
        @total_not_run=@total_not_run.to_i+1
      else
        @total_not_run=value
      end
    end
    #This method sets the total amount of found crash files
    #
    # === params
    # value: total not run value
    # === returns
    # nil
    # === raises
    def set_total_crash_files(value)
      @total_crash_files=@total_crash_files.to_i+value.to_i
    end
    #This method sets the total amount of device resets
    #
    # === params
    # value: total not run value
    # === returns
    # nil
    # === raises
    def set_total_device_resets(value)
      @total_device_resets=@total_device_resets.to_i+value.to_i
    end

    #This method sets the memory amount end
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_memory_amount_end(value)
      @memory_amount_end=value
    end
    #This method sets the memory amount start
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_memory_amount_start(value)
      @memory_amount_start=value
    end
    #This method sets the memory amount total
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_memory_amount_total(value)
      @memory_amount_total=value
    end

    #This method gets the not run cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_not_run_cases_arr()
      #@not_run_cases_arr
      read_result_storage('not_run')
    end
    #This method gets the passed cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_passed_cases_arr()
      #@passed_cases_arr
      read_result_storage('passed')
    end
    #This method gets the failed cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_failed_cases_arr()
      #@failed_cases_arr
      read_result_storage('failed')
    end
    #This method gets the failed cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_all_cases_arr()
      #@all_cases_arr
      read_result_storage('all')
    end

    #This method gets reporting groups
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_reporting_groups()
      @reporting_groups=$parameters[ :report_groups, nil ]
      if @reporting_groups==nil
        @reporting_groups=@generic_reporting_groups
      end
      @reporting_groups
    end

    #This method gets user created data
    #
    # === params
    # nil
    # === returns
    # the testcase data and column objects
    # === raises
    def get_user_data()
      return @test_case_user_data,@test_case_user_data_columns
    end

    #This method sets user data to display in chronological table
    #
    # === params
    # nil
    # === returns
    # the testcase data and column objects
    # === raises
    def set_user_chronological_table_data(value)
      if (value==nil)
        @test_case_user_chronological_table_data=Hash.new
      else
        @test_case_user_chronological_table_data=value
      end
    end
    #This method will parse duplicate groups out
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def check_if_group_exists_groups(groups,new_group_item)
      if groups.include? new_group_item
        true
      else
        false
      end
    end
    #This method creates a new TDriver test report folder when testing is started
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def  initialize_tdriver_report_folder()
      t = Time.now
      b_fixed_report_folder=false
      @start_time=t
      @reporter_base_folder = $parameters[ :report_outputter_path, 'tdriver_reports/' ]
      if $parameters[ :report_outputter_folder, nil ] != nil
        @report_folder=@reporter_base_folder+$parameters[ :report_outputter_folder, nil ]
        b_fixed_report_folder=true
      else
        @report_folder=@reporter_base_folder+"test_run_"+t.strftime( "%Y%m%d%H%M%S" )
      end

      begin
        #check if report directory exists
        if File::directory?(@report_folder)==false
          FileUtils.mkdir_p @report_folder+'/environment'
          FileUtils.mkdir_p @report_folder+'/cases'
          FileUtils.mkdir_p @report_folder+'/junit_xml'
        else
          if b_fixed_report_folder==true
            FileUtils::remove_entry_secure(@report_folder, :force => true)
            FileUtils.mkdir_p @report_folder+'/environment'
            FileUtils.mkdir_p @report_folder+'/cases'
            FileUtils.mkdir_p @report_folder+'/junit_xml'
          end
        end
        write_style_sheet(@report_folder+'/tdriver_report_style.css')
        write_page_start(@report_folder+'/cases/1_passed_index.html','Passed')
        write_page_end(@report_folder+'/cases/1_passed_index.html')
        write_page_start(@report_folder+'/cases/1_failed_index.html','Failed')
        write_page_end(@report_folder+'/cases/1_failed_index.html')
        write_page_start(@report_folder+'/cases/1_not_run_index.html','Not run')
        write_page_end(@report_folder+'/cases/1_not_run_index.html')
        write_page_start(@report_folder+'/cases/1_total_run_index.html','Total run')
        write_page_end(@report_folder+'/cases/1_total_run_index.html')
        write_page_start(@report_folder+'/cases/tdriver_log_index.html','TDriver log')
        write_page_end(@report_folder+'/cases/tdriver_log_index.html')
        write_page_start(@report_folder+'/cases/statistics_index.html','Statistics')
        write_page_end(@report_folder+'/cases/statistics_index.html')
        if $parameters[ :report_generate_rdoc, 'false' ]=='true'
          if $parameters[ :ats4_error_recovery_enabled, 'false' ]=='true'
            ats4_drop_folder_arr=@report_folder.split('ats4-results')
            system("rdoc --include #{ats4_drop_folder_arr[0]}/* --exclude test_run --op #{@report_folder}/doc")
            puts "RDoc generated from test folder: #{ats4_drop_folder_arr[0]}/*"
          else
            system("rdoc --exclude test_run --op #{@report_folder}/doc")
            puts "RDoc generated from test folder: #{Dir.pwd}"
          end
          
          
        end
      rescue Exception => e
        raise e, "Unable to create report folder: #{@report_folder}", caller
      end
      return nil
    end

    #This method generates the tdriver test run summary page grouped by test case
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def group_results_by_test_case()
      @all_cases_arr=read_result_storage('all')
      created_grouped_test_result=[]

      @all_cases_arr.each do |test_case|
        #name, status
        tc=[test_case[7],test_case[0]]
        if !created_grouped_test_result.include?(tc)
          update_test_case_summary_page(test_case[7],false,"Test: #{test_case[0]} Result: #{test_case[7]}",test_case[0])
          created_grouped_test_result << tc
        end
      end

    end

    #This method updates the tdriver test run summary page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_summary_page(status,exit_trace=nil)
      begin
        #Calculate run time
        @run_time=Time.now-@start_time
        if status=='inprogress'
          write_page_start(@report_folder+'/index.html','TDriver test results')
          write_summary_body(@report_folder+'/index.html',@start_time,'Tests Ongoing...',@run_time,@total_run,@total_passed,@total_failed,@total_not_run,@total_crash_files,@total_device_resets,@connection_errors)
          write_page_end(@report_folder+'/index.html')
        else
          all_cases_arr=read_result_storage('all')
          write_page_start(@report_folder+'/index.html','TDriver test results')
          write_summary_body(@report_folder+'/index.html',@start_time,@end_time,@run_time,@total_run,@total_passed,@total_failed,@total_not_run,@total_crash_files,@total_device_resets,@connection_errors,all_cases_arr)
          write_page_end(@report_folder+'/index.html')
        end
        if exit_trace
          write_page_start(@report_folder+'/exit.html','TDriver test results')
          write_exit_body(@report_folder+'/exit.html',exit_trace,@report_folder)
          write_page_end(@report_folder+'/exit.html')
        end
      rescue Exception => e
        raise e, "Unable to update summary page", e.backtrace
      end
      return nil
    end
    #This method updates the tdriver test run enviroment page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_environment_page()
      begin
        sw_version='-'
        variant='-'
        product='-'
        language='-'
        loc='-'
        #Copy behaviour and parameter xml files in to the report folder
        if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform || /mingw32/ =~ MobyUtil::EnvironmentHelper.ruby_platform
          FileUtils.cp_r 'C:/tdriver/behaviours', @report_folder+'/environment' if File.directory?('C:/tdriver/behaviours')
          FileUtils.cp_r 'C:/tdriver/templates', @report_folder+'/environment' if File.directory?('C:/tdriver/templates')
          FileUtils.cp_r 'C:/tdriver/defaults', @report_folder+'/environment' if File.directory?('C:/tdriver/defaults')
          FileUtils.copy('C:/tdriver/tdriver_parameters.xml',@report_folder+'/environment/tdriver_parameters.xml') if File.file?('C:/tdriver/tdriver_parameters.xml')
        else
          FileUtils.cp_r '/etc/tdriver/behaviours', @report_folder+'/environment' if File.directory?('/etc/tdriver/behaviours')
          FileUtils.cp_r '/etc/tdriver/templates', @report_folder+'/environment' if File.directory?('/etc/tdriver/templates')
          FileUtils.cp_r '/etc/tdriver/defaults', @report_folder+'/environment' if File.directory?('/etc/tdriver/defaults')
          FileUtils.copy('/etc/tdriver/tdriver_parameters.xml',@report_folder+'/environment/tdriver_parameters.xml') if File.file?('/etc/tdriver/tdriver_parameters.xml')
        end
        if $parameters[ :report_monitor_memory, 'false']=='true'
          TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
            if sut_attributes[:is_connected]
              @memory_amount_start=get_sut_used_memory(sut_id, sut_attributes) if @memory_amount_start==nil || @memory_amount_start=='-'
              @memory_amount_end=get_sut_used_memory(sut_id, sut_attributes)
              @memory_amount_total=get_sut_total_memory(sut_id, sut_attributes)
              @memory_amount_start='-' if @memory_amount_start==nil
              @memory_amount_end='-' if @memory_amount_end==nil
              @memory_amount_total='-' if @memory_amount_total==nil
            end
          end
        end
        if $parameters[ :report_collect_environment_data_from_sut, 'true']=='true'
          TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
            begin
              if sut_attributes[:is_connected]
                sw_version=get_sut_sw_version(sut_id, sut_attributes)
                variant=get_sut_lang_version(sut_id, sut_attributes)
                @memory_amount_start=get_sut_used_memory(sut_id, sut_attributes) if @memory_amount_start==nil || @memory_amount_start=='-'
                @memory_amount_end=get_sut_used_memory(sut_id, sut_attributes)
                @memory_amount_total=get_sut_total_memory(sut_id, sut_attributes)
                product=$parameters[sut_id][:product]
                language=$parameters[sut_id][:language]
                loc=$parameters[sut_id][:localisation_server_database_tablename]
              end
              @memory_amount_start='-' if @memory_amount_start==nil
              @memory_amount_end='-' if @memory_amount_end==nil
              @memory_amount_total='-' if @memory_amount_total==nil

              sw_version='-' if sw_version==nil
              variant='-' if variant==nil
              product='-' if product==nil
              language='-' if language==nil
              loc='-' if loc==nil
            rescue
            end
          end
        end

        write_page_start(@report_folder+'/environment/index.html','TDriver test environment')
        write_environment_body(@report_folder+'/environment/index.html',RUBY_PLATFORM,sw_version,variant,product,language,loc)
        write_page_end(@report_folder+'/environment/index.html')
        $new_junit_xml_results.test_suite_properties(RUBY_PLATFORM,sw_version,variant,product,language,loc,@memory_amount_total,@memory_amount_start,@memory_amount_end)
      rescue Exception => e
        p e.message
        p e.backtrace
        raise e, "Unable to update environment page"
      end
      return nil
    end
    #This method updates the tdriver log page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_tdriver_log_page()
      begin
        write_page_start(@report_folder+'/cases/tdriver_log_index.html','TDriver log')
        write_tdriver_log_body(@report_folder+'/cases/tdriver_log_index.html',@test_run_behaviour_log)
        write_page_end(@report_folder+'/cases/tdriver_log_index.html')
      rescue Exception => e
        raise e
      end
      return nil
    end
    #This method gets the sut langugage version
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_lang_version(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      lang_version='-'
      begin
        if $parameters[sut_id][:type]=='S60' || $parameters[sut_id][:type]=='Symbian'
          lang_version=sut_attributes[:sut].sysinfo( :Lang_version )
        end
        if $parameters[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            lang_version=0
          else
            lang_version=0
          end
        end
      rescue
      ensure
        if $parameters[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return lang_version
      end
    end
    #This method gets the sut sw version
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_sw_version(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      sw_version='-'
      begin
        if $parameters[sut_id][:type]=='S60' || $parameters[sut_id][:type]=='Symbian'
          sw_version=sut_attributes[:sut].sysinfo( :Sw_version )
        end
        if $parameters[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            sw_version=0
          else
            sw_version=0
          end
        end
      rescue
      ensure
        if $parameters[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return sw_version
      end
    end
    #This method gets the sut used memory amount
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_used_memory(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      memory=0
      begin
        if $parameters[sut_id][:type]=='S60' || $parameters[sut_id][:type]=='Symbian'
          memory=sut_attributes[:sut].sysinfo( :Get_used_ram )
        end
        if $parameters[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            memory=0
          else
            memory=0
          end
        end
      rescue
      ensure
        if $parameters[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return memory
      end

    end
    #This method gets the sut total memory amount
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_total_memory(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      memory=0
      begin
        if $parameters[sut_id][:type]=='S60' || $parameters[sut_id][:type]=='Symbian'
          memory=sut_attributes[:sut].sysinfo( :Get_total_ram )
        end
        if $parameters[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            memory=0
          else
            memory=0
          end
        end
      rescue
      ensure
        if $parameters[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return  memory
      end
    end
    #This method gets the sut total dump count
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_total_dump_count(sut_id, sut_attributes)

      dump_count=sut_attributes[:sut].dump_count
      @total_dump_count[sut_id.to_sym]=dump_count
      @total_dump_count

    end

    #This method gets the sut total received data
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_total_received_data(sut_id, sut_attributes)
      data=sut_attributes[:sut].received_data
      @total_received_data[sut_id.to_sym]=data
      @total_received_data
    end

    #This method gets the sut total sent data
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_total_sent_data(sut_id, sut_attributes)
      data=sut_attributes[:sut].sent_data
      @total_sent_data[sut_id.to_sym]=data
      @total_sent_data
    end

    def calculate_total_values_from_hash(values)
      total=0
      values.each_value do |val|
        total+=val
      end
      total
    end

    def write_to_result_storage(status,
        testcase,
        group,
        reboots=0,
        crashes=0,
        start_time=nil,
        user_data=nil,
        duration=0,
        memory_usage=0,
        index=0,
        log='',
        comment='',
        link='',
        total_dump=0,
        total_sent=0,
        total_received=0,
        user_data_rows=nil,
        user_data_columns=nil,
        connection_errors=0)
      
      while $result_storage_in_use==true
        sleep 1
      end
      $result_storage_in_use=true
      begin
        storage_file=nil

        if @report_short_folders=='true'
          html_link=status+'_'+index.to_s+'/index.html' if link==''
        else
          html_link=status+'_'+index.to_s+'_'+testcase+'/index.html' if link==''
        end


        storage_file='all_cases.xml'

        file=@report_folder+'/'+storage_file

        if File.exist?(file)
          io = File.open(file, 'r')
          xml_data = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
          io.close
          test = Nokogiri::XML::Node.new("test",xml_data)
          test_name = Nokogiri::XML::Node.new("name",test)
          test_name.content = testcase
          test_group = Nokogiri::XML::Node.new("group",test)
          test_group.content = group
          test_reboots = Nokogiri::XML::Node.new("reboots",test)
          test_reboots.content = reboots
          test_crashes = Nokogiri::XML::Node.new("crashes",test)
          test_crashes.content = crashes
          test_start_time = Nokogiri::XML::Node.new("start_time",test)
          test_start_time.content = start_time.strftime("%d.%m.%Y %H:%M:%S")
          test_duration = Nokogiri::XML::Node.new("duration",test)
          test_duration.content = duration
          test_memory_usage = Nokogiri::XML::Node.new("memory_usage",test)
          test_memory_usage.content = memory_usage
          test_status = Nokogiri::XML::Node.new("status",test)
          test_status.content = status
          test_index = Nokogiri::XML::Node.new("index",test)
          test_index.content = index
          test_log = Nokogiri::XML::Node.new("log",test)
          test_log.content = log
          test_comment = Nokogiri::XML::Node.new("comment",test)
          test_comment.content = comment
          test_link = Nokogiri::XML::Node.new("link",test)
          test_link.content = html_link
          test_connection_errors = Nokogiri::XML::Node.new("connection_errors",test)
          test_connection_errors.content = connection_errors
          test_dump_count = Nokogiri::XML::Node.new("dump_count",test)
          test_dump_count.content = calculate_total_values_from_hash(total_dump)
          test_sent_bytes = Nokogiri::XML::Node.new("sent_bytes",test)
          test_sent_bytes.content = calculate_total_values_from_hash(total_sent)
          test_received_bytes = Nokogiri::XML::Node.new("received_bytes",test)
          test_received_bytes.content = calculate_total_values_from_hash(total_received)

          test << test_name
          test << test_group
          test << test_reboots
          test << test_crashes
          test << test_start_time
          test << test_duration
          test << test_memory_usage
          test << test_status
          test << test_index
          test << test_log
          test << test_comment
          test << test_link
          test << test_connection_errors
          test << test_dump_count
          test << test_sent_bytes
          test << test_received_bytes

          if user_data!=nil && !user_data.empty?
            test_data = Nokogiri::XML::Node.new("user_display_data",test)
            user_data.each { |key,value|
              data_value=Nokogiri::XML::Node.new("data",test_data)
              data_value.content = value.to_s
              data_value.set_attribute("id",key.to_s)
              test_data << data_value
            }
            test<<test_data
          end


          if user_data_rows!=nil && !user_data_columns.empty?

            test_data = Nokogiri::XML::Node.new("user_table_data",test)
            #create the table rows
            user_data_rows.each do |row_hash|
              row_hash.sort{|a,b| a[0]<=>b[0]}.each do |value|
                data_value=Nokogiri::XML::Node.new("column",test_data)
                data_value.set_attribute("name",value[0].to_s)
                data_value.content = value[1].to_s
                test_data << data_value
              end
            end
            test<<test_data
          end

          if @test_case_user_xml_data!=nil
            test_data = Nokogiri::XML::Node.new("non_display_data",test)
            #create the table rows
            @test_case_user_xml_data.each_key do |key|              
                data_value=Nokogiri::XML::Node.new("data",test_data)
                data_value.set_attribute("id",key.to_s)
                data_value.content = @test_case_user_xml_data[key].to_s
                test_data << data_value              
            end
            test<<test_data
          end

          xml_data.root.add_child(test)
          File.open(file, 'wb') {|f| f.write(xml_data) }
          test=nil
          xml_data=nil
        else
          counter=0
          if user_data!=nil && !user_data.empty?
            #to avoid odd number list for hash error!
            user_data_keys = user_data.keys
            user_data_values = user_data.values
            counter = user_data_values.size-1
          end

          builder = Nokogiri::XML::Builder.new do |xml|
            xml.tests {
              xml.test {
                xml.name testcase
                xml.group group
                xml.reboots reboots
                xml.crashes crashes
                xml.start_time start_time.strftime("%d.%m.%Y %H:%M:%S")
                xml.duration duration
                xml.memory_usage memory_usage
                xml.status status
                xml.index index
                xml.log log
                xml.comment comment
                xml.link html_link
                xml.connection_errors connection_errors
                xml.dump_count calculate_total_values_from_hash(total_dump)
                xml.sent_bytes calculate_total_values_from_hash(total_sent)
                xml.received_bytes calculate_total_values_from_hash(total_received)

                if user_data!=nil && !user_data.empty?
                  xml.user_display_data {
                    (0..counter).each { |i|
                      xml.data("id"=>user_data_keys.at(i).to_s){
                        xml.text user_data_values.at(i).to_s{
                        }
                      }
                    }
                  }
                end

                if user_data_rows!=nil && !user_data_columns.empty?

                  xml.user_table_data{
                    #create the table rows
                    user_data_rows.each do |row_hash|
                      row_hash.sort{|a,b| a[0]<=>b[0]}.each do |value|
                        xml.column("name"=>value[0].to_s){
                          xml.text value[1].to_s
                        }
                      end
                    end
                  }

                end
                
                
                if @test_case_user_xml_data!=nil

                  xml.non_display_data{
                    #create the table rows
                    @test_case_user_xml_data.each_key do |key|
                      
                        xml.data("id"=>key.to_s){
                          xml.text @test_case_user_xml_data[key].to_s
                        }
           
                    end
                  }

                end
                
              }
            }
          end
          File.open(file, 'w') {|f| f.write(builder.to_xml) }
        end
        $result_storage_in_use=false
        builder=nil
      rescue Nokogiri::XML::SyntaxError => e
        $result_storage_in_use=false
        $stderr.puts "caught exception when writing results: #{e}"
      end
    end

    def parse_results_for_current_test( by_status )

      ret_xml = nil
      while $result_storage_in_use==true
        sleep 1
      end
      $result_storage_in_use=true
      begin
        result_storage=nil
        result_storage=Array.new
        storage_file='all_cases.xml'


        file=@report_folder+'/'+storage_file
        if File.exist?(file)
          io = File.open(file, 'r')
          ret_xml = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }

          io.close

          status_search = ""

          case by_status
          when "all"
            status_search = ""
          when "passed"
            status_search = " and (status='"
            status_search << @pass_statuses.join("' or status='")
            status_search << "')"
          when "failed"
            status_search = " and (status='"
            status_search << @fail_statuses.join("' or status='")
            status_search << "')"
          when "not run"
            status_search = " and (status='"
            status_search << @not_run_statuses.join("' or status='")
            status_search << "')"
          else
            status_search = " and status='" + by_status + "'"
          end

          ret_xml = ret_xml.root.xpath("//tests/test[name='#{$new_test_case.test_case_name}' and group='#{$new_test_case.test_case_group}'#{status_search}]")
        else
          #puts "No file " << storage_file
        end
      rescue Exception => e
        $result_storage_in_use=false
        raise e

      end

      $result_storage_in_use=false

      ret_xml

    end

    def read_result_storage(results,case_name=nil)
      while $result_storage_in_use==true
        sleep 1
      end
      $result_storage_in_use=true
      begin
        result_storage=nil
        result_storage=Array.new
        storage_file='all_cases.xml'

        nodes=Nokogiri::XML::NodeSet

        file=@report_folder+'/'+storage_file
        if File.exist?(file)
          io = File.open(file, 'rb')
          xml_data = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
          io.close
          if case_name
            nodes=xml_data.root.xpath("//tests/test[name='#{case_name}' and status='#{results.gsub('_',' ')}']")
          elsif results=='crash'
            nodes=xml_data.root.xpath("//tests/test[crashes>0]")
          elsif results=='reboot'
            nodes=xml_data.root.xpath("//tests/test[reboots>0]")
          elsif results=='connection_errors'
            nodes=xml_data.root.xpath("//tests/test[connection_errors>0]")
          elsif results!='all' && results!='crash' && results!='reboot' && results!='connection_errors'
            case results
            when 'passed'

                nodes=xml_data.root.xpath("//tests/test[status='#{@pass_statuses.first}']")

            when 'failed'

                nodes=xml_data.root.xpath("//tests/test[status='#{@fail_statuses.first}']")

            when 'not_run'

                nodes=xml_data.root.xpath("//tests/test[status='#{@not_run_statuses.first}']")

            end
          else
            if @report_exclude_passed_cases=='true'
              nodes=xml_data.root.xpath("//tests/test[status!='passed']")
            else
              nodes=xml_data.root.xpath("//tests/test")
            end

          end

          nodes.each do |node|
            value=node.search("name").text #0
            group=node.search("group").text #1
            reboots=node.search("reboots").text #2
            crashes=node.search("crashes").text #3
            start_time=node.search("start_time").text #4
            duration="%0.2f" % node.search("duration").text #5
            memory_usage=node.search("memory_usage").text #6
            status=node.search("status").text #7
            index=node.search("index").text #8
            log=node.search("log").text #9
            comment=node.search("comment").text #10
            link=node.search("link").text #11
            dump_count=node.search("dump_count").text #12
            sent_bytes=node.search("sent_bytes").text #13
            received_bytes=node.search("received_bytes").text #14
            connection_errors=node.search("connection_errors").text #15
            user_data = Hash.new
            node.xpath("user_display_data/data").each do |data_node|
              value_name =  data_node.get_attribute("id")
              val = data_node.text
              user_data[value_name] = val
            end

            current_record=[value,
              group,
              reboots,
              crashes,
              start_time,
              duration,
              memory_usage,
              status,
              index,
              log,
              comment,
              link,
              user_data,
              dump_count,
              sent_bytes,
              received_bytes,
              connection_errors
            ]

            result_storage << current_record

          end
          xml_data=nil
          $result_storage_in_use=false
          result_storage
        else
          $result_storage_in_use=false
          result_storage
        end
      rescue Nokogiri::XML::SyntaxError => e
        $result_storage_in_use=false
        $stderr.puts "caught exception when reading results: #{e}"
        result_storage
      end
    end

    def delete_result_storage()
      storage_file='passed_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end

      storage_file='failed_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end

      storage_file='not_run_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end

      storage_file='all_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end
    end
    #This method disconencts the connected devices
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def disconnect_connected_devices()
      if $parameters[ :report_disconnect_connected_devices, false ] == 'true'
        TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
          sut_attributes[:sut].disconnect() if sut_attributes[:is_connected]
        end
      end
    end

    def split_array(splittable_array,chunks)
      a = []
      splittable_array.each_with_index do |x,i|
        a << [] if i % chunks == 0
        a.last << x
      end
      a
    end



    #This method updates the tdriver test run enviroment page
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def update_test_case_summary_page(status,rewrite=false,title="",test_case_name=nil,tc_result_arr=nil)
      @cases_arr=Array.new
      search_case = nil
      if @pass_statuses.include?(status)
        search_case = "passed"
        return if @report_exclude_passed_cases=='true'
      elsif @fail_statuses.include?(status)
        search_case = "failed"
      elsif @not_run_statuses.include?(status)
        search_case = "not_run"
      else
        search_case = status
      end
      status=status.gsub(' ','_')
      if test_case_name
        @cases_arr=read_result_storage(search_case,test_case_name)
      else
        @cases_arr=read_result_storage(search_case)
      end
      splitted_arr=Array.new
      splitted_arr=split_array(@cases_arr,@pages.to_i)
      page=1
      splitted_arr.each do |case_arr|

        if test_case_name
          if @report_pages_ready.include?("#{page}_#{status}_#{test_case_name}")==false || rewrite==true
            write_page_start(@report_folder+"/cases/#{page}_#{status}_#{test_case_name}_index.html",title,page,splitted_arr.length)
            write_test_case_summary_body(@report_folder+"/cases/#{page}_#{status}_#{test_case_name}_index.html",status,case_arr,nil)
            page_ready=write_page_end(@report_folder+"/cases/#{page}_#{status}_#{test_case_name}_index.html",page,splitted_arr.length)
          end
        else
          if @report_pages_ready.include?("#{page}_#{status}")==false || rewrite==true
            write_page_start(@report_folder+"/cases/#{page}_#{status}_index.html",title,page,splitted_arr.length)
            write_test_case_summary_body(@report_folder+"/cases/#{page}_#{status}_index.html",status,case_arr,nil)
            page_ready=write_page_end(@report_folder+"/cases/#{page}_#{status}_index.html",page,splitted_arr.length)
          end
        end
        if page_ready!=nil
          @report_pages_ready << "#{page_ready}_#{status}"
        end
        page_ready=nil
        page+=1
      end

    end
    #This method updates the tdriver test run enviroment pages
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def update_test_case_summary_pages(status,rewrite=false)

      @all_cases_arr=Array.new
      begin
        case status
        when 'passed'
          update_test_case_summary_page(status,rewrite,'Passed')

        when 'failed'
          update_test_case_summary_page(status,rewrite,'Failed')

        when 'not run'
          update_test_case_summary_page('not_run',rewrite,'Not run')

        when 'statistics'
          @all_cases_arr=read_result_storage('all')
          write_page_start(@report_folder+'/cases/statistics_index.html','Statistics')
          write_test_case_summary_body(@report_folder+'/cases/statistics_index.html','statistics',@all_cases_arr)
          write_duration_graph(@report_folder+'/cases/statistics_index.html', @report_folder, 'duration_graph.png', @all_cases_arr) if @duration_graph=='true'
          write_page_end(@report_folder+'/cases/statistics_index.html')
        when 'all'
          @all_cases_arr=read_result_storage(status)
          splitted_arr=Array.new
          splitted_arr=split_array(@all_cases_arr,@pages.to_i)
          page=1
          splitted_arr.each do |case_arr|
            if File.exist?(@report_folder+"/cases/#{page+1}_total_run_index.html")==false || rewrite==true
              if @report_pages_ready.include?("#{page}_all")==false || rewrite==true
                write_page_start(@report_folder+"/cases/#{page}_total_run_index.html",'Total run',page,splitted_arr.length)
                write_page_start(@report_folder+"/cases/#{page}_chronological_total_run_index.html",'Total run',page,splitted_arr.length)
                write_test_case_summary_body(@report_folder+"/cases/#{page}_total_run_index.html",'total run',case_arr,@report_folder+"/cases/#{page}_chronological_total_run_index.html",page)
              end
            end
            write_page_end(@report_folder+"/cases/#{page}_chronological_total_run_index.html",page,splitted_arr.length) if @report_pages_ready.include?("#{page}_all")==false || rewrite==true
            page_ready=write_page_end(@report_folder+"/cases/#{page}_total_run_index.html",page,splitted_arr.length) if @report_pages_ready.include?("#{page}_all")==false || rewrite==true

            if page_ready!=nil
              @report_pages_ready << "#{page_ready}_all"
            end
            page_ready=nil
            page+=1
          end
        end
        @all_cases_arr=nil
        update_test_case_summary_pages_for_crashes_and_reboots(rewrite)
      rescue Exception => e
        puts e.backtrace 
        raise e, "Unable to update test case summary pages", caller        
      end
      return nil
    end

    def update_test_case_summary_pages_for_crashes_and_reboots(rewrite=false)

      begin
        update_test_case_summary_page('crash',rewrite,'Crash')
        update_test_case_summary_page('reboot',rewrite,'Reboot')
        update_test_case_summary_page('connection_errors',rewrite,'Connection Errors')
      rescue Exception => e
        raise e, "Unable to update test case summary pages for crashes and reboots", caller
      end
      return nil
    end

    def create_csv
      storage_file='all_cases.xml'
      csv_file = 'all_cases.csv'
      csv_array = Array.new
      not_added=false

      file=@report_folder+'/'+storage_file
      csv =  nil
      begin
        if File.exist?(file)
          io = File.open(file, 'r')
          csv = File.new(@report_folder+'/'+ csv_file, 'w')
          xml_data = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
          io.close
          xml_data.root.xpath("//tests/test").each do |node|

            line=Array.new
            first_line=Array.new

            value=node.search("name").text
            first_line<<"name" if !not_added
            line<<value
            start_time=node.search("start_time").text
            first_line<<"start_time" if !not_added
            line<<start_time
            duration=node.search("duration").text
            first_line<<"duration" if !not_added
            line<<duration
            memory_usage=node.search("memory_usage").text
            first_line<<"memory_usage" if !not_added
            line<<memory_usage
            status=node.search("status").text
            first_line<<"status" if !not_added
            line<<status

            node.xpath("user_display_data/data").each do |data_node|
              value_name = data_node.get_attribute("id")
              value = data_node.text
              first_line<<value_name if !not_added
              line<<value
            end

            csv.puts(first_line.join(",")) if !not_added
            csv.puts(line.join(","))
            not_added=true
          end
          csv.close
        else
          puts "Unable to create csv file"
        end
      rescue Exception => e
        puts "Error creating csv file"
        puts e.to_s
      end
    end

  end
end
