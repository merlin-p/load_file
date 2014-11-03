require 'resque'
module LoadFile
  class Job
    # Resque queue name
    @queue = :loadfile

    # Public: perform the download and unpack the archive
    def self.perform(remote_uri, save_location = nil, user = nil, password = nil)
      result = LoadFile.from_uri(remote_uri, save_location, user, password)
      if result.success?
        from_archive(result.params[:file], save_location)
      else
        result
      end
    end
  end

  # Public: adds a job to reqeue queue
  def self.add_job(remote_uri, save_location = nil, user = nil, password = nil)
    Resque.enqueue(LoadFile::Job, remote_uri, save_location, user, password)
  end
end
