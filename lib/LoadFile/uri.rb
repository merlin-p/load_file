module LoadFile
  class URI
    # Public: returns the current adapter
    attr_reader :adapter

    # Public: setup new default Adapter
    # 
    # remote_uri - the remote URI to download
    # local_path - where to save the files. PWD is used if omitted (default: nil)
    #
    # Examples
    #
    #   FileLoad::URI.new("http://ninja/file.gz").load
    #   FileLoad::URI.new("http://ninja/file.zip", "/data").auth("user", "password").load
    #
    # Returns LoadFile::Result
    def initialize(remote_uri, local_path = nil)
      @adapter = LoadFile::Adapter::DEFAULT.new(remote_uri, local_path)
    end

    # Public: en-/disable SSL verification
    #
    # state - true or false
    def verify_ssl=(state)
      @adapter.verify_ssl = state
    end

    # Public: get SSL verification state
    #
    # Returns boolean
    def verify_ssl
      @adapter.verify_ssl
    end

    # Public: set HTTP authentication credentials
    #
    # Returns self
    def auth(user, password)
      @adapter.auth user, password
      self
    end

    # Public: execute the download
    #
    # Returns result Hash
    def load
      @adapter.load
      @adapter.result
    end
  end
end