require 'rubygems'
require 'rubygems/package'
require 'zlib'
require 'fileutils'
require 'stringio'

def ungzip(gzipfile)
    tarzip_name = File.basename(gzipfile, ".gz")
    gzipfile_path = File.dirname(gzipfile)
    FileUtils.cd(gzipfile_path)
    if File.exist?(tarzip_name) 
        puts "#{tarzip_name} already exists"
        return gzipfile_path << "/" << tarzip_name
    else
        tar_stream = File.open(tarzip_name,"ab+") 
        tarfile = File.open(gzipfile, "rb")
        z = Zlib::GzipReader.new(tarfile)

        while buff = z.read(4096)
            tar_stream.write(buff)
        end
        z.close
        tar_stream.close()
        return gzipfile_path << "/" << tarzip_name
    end 
 end


def untar(tarzip_path_full, destination)
    tarzip_name = File.basename(tarzip_path_full)
    tarzip_path = File.dirname(tarzip_path_full)
    FileUtils.cd(tarzip_path) 
    tar_stream = File.open(tarzip_name)
    Gem::Package::TarReader.new tar_stream do |tar|
      tar.each do |tarfile|
        destination_file = File.join destination, tarfile.full_name

        if tarfile.directory?
            FileUtils.mkdir_p destination_file
        else
            destination_directory = File.dirname(destination_file)
            FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
            File.open destination_file, "wb" do |f|
              f.print tarfile.read
            end
        end
      end
    end
end
# usage :   
tarzip_path_full= ungzip("C:/test.tar.gz")
untar(tarzip_path_full,"C:/Test/")
