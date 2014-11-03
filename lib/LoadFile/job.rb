require 'resque'
module LoadFile
  class Job
    # Resque queue name
    @queue = :loadfile

    # Public: perform the download and unpack the archive
    def self.perform(remote_uri, local_path = nil, user = nil, password = nil)
      result = LoadFile.from_uri(remote_uri, local_path, user, password)
      if result.success?
        from_archive(result.params[:file], local_path)
      else
        result
      end
    end
  end

  # Public: adds a job to reqeue queue
  def self.add_job(remote_uri, local_path = nil, user = nil, password = nil)
    Resque.enqueue(LoadFile::Job, remote_uri, local_path, user, password)
  end
end
