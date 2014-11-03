require 'net/https'
require 'digest/md5'

module LoadFile
  module Adapter
    class NetHTTP < LoadFile::Adapter::Base
      attr_reader :remote_uri, :local_path, :result, :target_file

      def initialize(remote_uri, local_path)
        @remote_uri, @local_path = remote_uri, local_path
        @local_path = Dir.pwd if @local_path.nil?
      end

      # Public: execute the request
      def load
        begin
          http_request do |response, file, size|
            @target_file ||= file_from_header(response) || @local_path
            if File.exists? @target_file
              check_target_file size
            else
              write_stream(file, response)
              check_written_file file
            end
          end
        rescue => e
          status LoadFile::Status::Error, e.message, e.backtrace
        end
      end

      private
        def check_target_file(size)
          if File.size(@target_file) == size
            status LoadFile::Status::FileRetrieved
          elsif size == -1
            status LoadFile::Status::Success
          end
        end

        def check_written_file(file)
          if File.readable?(file) && File.size(file)>0
            File.rename file, @target_file
            status LoadFile::Status::Success
          else
            status LoadFile::Status::Error, 'retrieved file not readable or empty'
          end
        end

        def http_request
          uri = URI(@remote_uri)
          file = temp_filename
          Net::HTTP.start(uri.host, uri.port,
            :use_ssl => uri.scheme == 'https',
            :verify_mode => 
              @verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
          ) do |http|
            code = http.head(uri.request_uri).code.to_i
            size = File.exists?(file) ? File.size(file) : 0
            if code >=200 && code < 300 && size > 0
              headers = { 'Range' => "bytes=#{size}-" }
            end
            request = Net::HTTP::Get.new uri.request_uri, headers ? headers : {}
            request.basic_auth @username, @password if !@username.nil?
            http.request(request) do |response|
              yield response, file, size_from_header(response)
            end
          end
        end

        def write_stream(file, response)
          File.open(file,'a+') do |f|
            response.read_body do |chunk|
              f.write chunk
            end
          end
        end

        def temp_filename
          default_name = ".loadfile-tmp-"+Digest::MD5.hexdigest(@remote_uri)
          if File.directory? @local_path
            File.join @local_path, default_name
          else
            @target_file = @local_path
          end
        end

        def file_from_header(header)
          if header.key?('content-disposition')
            matches = header['content-disposition'].match(/filename=(\"?)(.+)\1/)
            if matches.size == 3
              File.join @local_path, matches[2]
            end
          elsif File.directory?(@local_path)
            File.join @local_path, File.basename(URI(@remote_uri).path)
          end
        end

        def size_from_header(header)
          header.key?('content-length') ? header['content-length'].to_i : -1
        end
    end
  end
end