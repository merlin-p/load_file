module LoadFile
  module Status
    class Base
      attr_accessor :error, :trace, :input, :params, :output, :file

      def initialize(params={})
        params.each { |k,v| instance_variable_set("@#{k}", v) }
      end

      def success?
        @error.nil?
      end

      def fail?
        !success?
      end
    end

    class Success < Base
      CODE = 0
    end

    class Error < Base
      CODE = 1
    end

    class FileRetrieved < Base
      CODE = 2
    end
  end
end