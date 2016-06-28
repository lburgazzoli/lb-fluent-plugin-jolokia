#
#  Copyright 2013 the original author or authors.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

require 'fluent/input'
require 'httparty'
require 'json'

module Fluent
  
  class JolokiaInput < Input
    Plugin.register_input('jolokia',self)

    config_param :tag, :string, :default => nil
    config_param :jolokia_url, :string
    config_param :jolokia_auth, :string, :default => nil
    config_param :jmx_bean, :string
    config_param :jmx_attribute, :string, :default => nil
    config_param :jmx_path, :string, :default => nil
    config_param :run_interval, :time
    config_param :add_jolokia_url, :bool, :default => false
    config_param :extract_values_only, :bool, :default => false

    def initialize
      super
    end
    
    def configure(conf)
      super
    end
      
    def start
      super
      @finished = false
      @thread = Thread.new(&method(:run_periodic))
      @username, @password = @jolokia_auth.split(':') if @jolokia_auth
    end

    def shutdown
      @finished = true
      @thread.join
      super
    end

    # 
    # Main loop 
    #
    def run_periodic
      until @finished
        sleep @run_interval

        begin 
          tag         = @tag
          value       = get_attribute(@jmx_bean, @jmx_attribute, @jmx_path)
          value[:url] = @jolokia_url if @add_jolokia_url

          router.emit(
            tag, 
            Engine.now.to_i,
            value
          )
        rescue => e
          $log.warn "Failed to get JMX attribute, but ignored: #{e.message}"
        end
        
      end
    end  

    def get_attribute(mbean, attribute = nil, path = nil)
      opt             = { :type => 'read', :mbean => mbean }
      opt[:attribute] = attribute if attribute
      opt[:path]      = path if path

      post_data = { :body => JSON.generate(opt) }
      if @username and @password
        auth = {:username => @username, :password => @password}
        post_data[:basic_auth] = auth
      end

      resp = HTTParty.post(@jolokia_url, post_data)
      data = JSON.parse(resp.body)
      if data
        if @extract_values_only
          return data["value"]
        else
          return data
        end
      end

      return nil
    end
  end    
end
