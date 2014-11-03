module LoadFile
  module Adapter
    class Base
      attr_accessor :verify_ssl
      attr_reader :username, :password
      # Public: set http auth user and password
      def auth(username, password)
        @username, @password = username, password
      end
      
      def status(state, error = nil, trace = [])
        if state < LoadFile::Status::Base
          @result = state.new({
            :input => {
              :remote_uri     => @remote_uri,
              :local_path  => @local_path,
              :username       => @username,
              :password       => @password
            },
            :file    => @target_file,
            :error   => error,
            :trace   => trace
          })
        end
      end
    end
  end
end