require 'net/https'
require 'digest/md5'

module LoadFile
  module Adapter
    class NetHTTP < Base
      attr_reader :remote_uri, :local_path, :result, :target_file

      def initialize(remote_uri, local_path)
        @remote_uri = remote_uri
        @uri = URI(remote_uri)
        @local_path = local_path.nil? ? Dir.pwd : local_path
        @temp_file = temp_filename
      end

      # Public: execute the request
      def load
        begin
          http_request do |response|
            @target_file = file_from_header(response) || local_uri
            @remote_size = size_from_header(response)
            if File.exists? @target_file
              check_target_file
            else
              write_stream response
              check_written_file
            end
          end
        rescue => e
          status LoadFile::Status::Error, e.message, e.backtrace
        end
      end

      private
        def http_request
          Net::HTTP.start(@uri.host, @uri.port,
            :use_ssl => @uri.scheme == 'https',
            :verify_mode => 
              @verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
          ) do |http|
            http_range(http)
            http.request(get_request) do |response|
              yield response
            end
          end
        end

        def http_range(http)
          code = http.head(@uri.request_uri).code.to_i
          size = File.exists?(@temp_file) ? File.size(@temp_file) : 0
          if code >=200 && code < 300 && size > 0
            @headers = { 'Range' => "bytes=#{size}-" }
          end
        end

        def get_request
          @request = Net::HTTP::Get.new @uri.request_uri, @headers ? @headers : {}
        end

        def http_auth(request)
          @request.basic_auth @username, @password if !@username.nil?
        end

        def file_from_header(header)
          if header.key?('content-disposition')
            matches = header['content-disposition'].match(/filename=(\"?)(.+)\1/)
            File.join @local_path, matches[2] if matches.size == 3
          end
        end
        
        def size_from_header(header)
          header.key?('content-length') ? header['content-length'].to_i : -1
        end

        def write_stream(response)
          File.open(@temp_file,'a+') do |f|
            response.read_body do |chunk|
              f.write chunk
            end
          end
        end

        def check_target_file
          if File.size(@target_file) == @remote_size
            status LoadFile::Status::FileRetrieved
          elsif @remote_size == -1
            status LoadFile::Status::Success
          end
        end

        def check_written_file
          if File.readable?(@temp_file) && File.size(@temp_file)>0
            File.rename @temp_file, @target_file
            status LoadFile::Status::Success
          else
            status LoadFile::Status::Error, 'retrieved file not readable or empty'
          end
        end

        def temp_filename
          join_path ".loadfile-tmp-"+Digest::MD5.hexdigest(@remote_uri)
        end

        def local_uri
          join_path File.basename(@uri.path)
        end

        def join_path(name)
          if File.directory? @local_path
            File.join @local_path, name
          else
            @local_path
          end
        end
    end
  end
end