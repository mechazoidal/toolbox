#!ruby
require 'trollop'
require 'tempfile'

opts = Trollop::options do
  opt :file, 'FLV file to convert', :type=>:string
  opt :target, '(optional) name of target file', :type=>:string
  opt :outdir, '(optional) out dir', :type=>:string
  opt :verbose, 'verbose', :type=>:boolean
end
Trollop.die :file, "required" if opts[:file].nil?

OPT_PATH = '/opt/local/bin'
file_name = File.basename(opts[:file])
aac_file_path = file_name + '.aac'
outpath = opts[:outdir] || opts[:file].split('/')[0..-2].join('/')
outfile = opts[:target] || file_name + '.m4a'

if(opts[:verbose])
  puts "file_name: #{file_name}"
  puts "aac_file_path: #{aac_file_path}"
  puts "outpath: #{outpath}"
  puts "outfile: #{outfile}"
end

# TODO: clean up the outdir/outfile/out_loc mess
# TODO: set some basic ID3 tags as well?
Dir.mktmpdir do |dir|
  mpeg_string ="ffmpeg -i '#{opts[:file]}' -vn -acodec copy '#{File.join(dir, aac_file_path)}'"
  out_loc = opts[:outdir].nil? ? File.join(outpath, outfile) : outfile
  afconvert_string = "afconvert '#{File.join(dir, aac_file_path)}' '#{out_loc}' -f 'mp4f'"
  if(opts[:verbose])
    puts "mpeg_string: #{mpeg_string}"
    puts "afconvert_string: #{afconvert_string}"
  end
  system(mpeg_string)
  system(afconvert_string)
end

