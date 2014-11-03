require 'spec_helper'

describe LoadFile::Archive do
  describe '.initialize' do
    context 'invalid archive given' do
      it 'should raise an IOError' do
        expect { LoadFile::Archive.new('----invalid') }.to raise_error(IOError)
      end
    end

    context 'local_path omitted' do
      it 'should use Dir.pwd' do
        expect(LoadFile::Archive.new('testdata/test.zip').local_path).to eq(Dir.pwd)
      end
    end

    context 'local_path is given' do
      it 'should have local_path set' do
        location = '/tmp'
        expect(LoadFile::Archive.new('testdata/test.zip',location).local_path).to eq(location)
      end
    end
  end

  describe '.unpack' do
    %w(gzip zip).each do |type|
      context "unpacking #{type} archive" do
        it 'should return LoadFile::Status::Success' do
          Dir.mktmpdir do |dir|
            result = LoadFile::Archive.new("testdata/test.#{type}", dir).unpack
            expect(result).to be_a(LoadFile::Status::Success)
          end
        end

        it 'should have extracted a file' do
          Dir.mktmpdir do |dir|
            result = LoadFile::Archive.new("testdata/test.#{type}", dir).unpack
            expect(File.size(Dir[dir+"/*"].first)).not_to be_zero
          end
        end
      end
    end
  end
end