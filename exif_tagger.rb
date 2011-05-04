require 'trollop'
require 'fileutils'

opts = Trollop::options do
  version '1.0'
  banner <<-EOS
exif_tagger.rb
A simple wrapper to tag JPEG files using the 'exif' command-line tool
(since the exifr gem doesn't have write support)
EOS
  opt :filename, 'photo to be changed', :type=>:string, :required=>true
  opt :description, 'new description text', :type=>:string
  opt :creator, 'new creator text', :type=>:string
  opt :dry_run, "say instead of do (negates --copy)", :default=>false
  opt :copy, 'work on a copy of the file', :default=>true
end

Trollop.die("You need the 'exif' tool in your PATH for this script: http://libexif.sourceforge.net") if(%x{'exif' '-v'}.length == 0)
working_file = File.expand_path(opts[:filename])
Trollop.die('File must exist') unless File.exists?(working_file)

if(opts[:copy] && !opts[:dry_run])
  working_file.gsub!(/\.(jpg)$/i) {|s| ".copy." + $1}
  FileUtils.cp(File.expand_path(opts[:filename]), working_file)
end

tags = {'0x010e'=>opts[:description], 
        '0x013b'=>opts[:creator]
       }

tags.each_pair do |k,v|
  # TODO: verify that fields were written as expected?
  if(opts[:dry_run])
    puts ["exif", "-c", "--ifd=0", "--output=#{working_file}", "--tag=#{k}", "--set-value='#{v}'", "#{working_file}"].join(' ')
  else
    output = %x{"exif" "-c" "--ifd=0" "--output=#{working_file}" "--tag=#{k}" "--set-value=#{v}" "#{working_file}"}
    # since exif doesn't seem to have a --silent option.
    Trollop.die("exif complained!: #{output}") unless output.index(/^Wrote file '#{working_file}'.$/)
  end
end
