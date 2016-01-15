#
# Cookbook Name:: fluentd
#
# Copyright 2015, Felipe Cecagno
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Fluentd

  module Helpers
    def indent(value, indentation)
      " " * indentation + value
    end
    
    def print_hash(entry, indentation, indentation_increment)
      response = ""
      entry.each do |key, value|
        response += print_entry(key, value, indentation + indentation_increment, indentation_increment)
      end
      response
    end
    
    def print_entry(key, value, indentation, indentation_increment)
      response = ""
      if value.respond_to? "map"
        value.each do |entry|
          response += indent("<#{key}>\n", indentation)
          response += print_hash(entry, indentation, indentation_increment)
          response += indent("</#{key}>\n", indentation)
        end
      else
        response += indent("#{key.gsub(/^type$/, "@type")} #{value}\n", indentation)
      end
      response
    end
  end

end
