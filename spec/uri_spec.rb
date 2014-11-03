require 'webmock/rspec'

describe LoadFile::URI do
  before(:all) do
    file = 'testdata/test.zip'
    @file_stub = File.exists?(file) ? IO.read(file) : "\x0"
  end

  before(:each) do
    stub_request(:get, "http://user:pass@ninja/file.zip").
      to_return(:status => 200, :body => @file_stub, :headers => {})
    stub_request(:get, "http://ninja/file.zip").
      with(:headers => {
        'Accept'=>'*/*', 
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      }).
      to_return(:status => 200, :body => @file_stub, :headers => {})
    stub_request(:head, "http://ninja/file.zip").
      to_return(:status => 200, :headers => {})
  end

  describe '.initialize' do
    context 'no local_path given' do
      it 'should use Dir.pwd as local_path' do
        expect(LoadFile::URI.new("http://t").adapter.local_path).to eq(Dir.pwd)
      end
    end

    context 'local_path is given' do
      it 'should have local_path set' do
        location = '/tmp'
        expect(LoadFile::URI.new("http://t",location).adapter.local_path).to eq(location)
      end

      it 'should save to the given directory' do
        Dir.mktmpdir do |dir|
          result = LoadFile::URI.new("http://ninja/file.zip",dir).load
          expect(File.exists?(result.file)).to be true
        end
      end
    end
  end

  describe '.auth' do
    context 'http basic auth request' do
      it 'should load the file and have the expected content' do
        Dir.mktmpdir do |dir|
          loader = LoadFile::URI.new("http://ninja/file.zip",dir)
          loader.auth("user","pass")
          result = loader.load
          expect(File.exists?(result.file)).to be true
          expect(IO.read(result.file)).to eq(@file_stub)
          expect(result).to be_a(LoadFile::Status::Success)
        end
      end
    end
  end

  describe '.load' do
    context 'loading file from http' do
      it 'should load the file and have the expected content' do
        Dir.mktmpdir do |dir|
          result = LoadFile::URI.new("http://ninja/file.zip",dir).load
          expect(File.exists?(result.file)).to be true
          expect(IO.read(result.file)).to eq(@file_stub)
          expect(result).to be_a(LoadFile::Status::Success)
        end
      end
    end
  end
end