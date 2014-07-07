#!ruby
# Simple way to get JSON output from a structured vimwiki file
# assumes that blank lines delineate sections, and that lines are structured like:
# * <name>: <data>
# TODO: take an argument to determine line starting character

require 'trollop'
require 'json'

opts = Trollop::options do
  opt :file, "file to work on", :type=>:io, :required=>true
  opt :name, "name to use for section", :type=>:string, :required=>true
end

def split_sections(lines)
  lines.each_line.inject([]) do |acc, line|
    # a whitespace-only line indicates break of the section and start of a new group
    (line =~ /^\s+$/ or acc.empty?) ? acc << [] : acc.last << line
    acc
  end
end

def convert_group(lines)
  lines.inject({}) {|acc, line| acc[line[/^\*\W(.+)\: /, 1]] = line[/:\W(.+)$/,1] if line.length > 1; acc}
end

sections = split_sections(opts[:file])

STDOUT << {opts[:name] => sections.collect{|x| convert_group(x)} }.to_json
