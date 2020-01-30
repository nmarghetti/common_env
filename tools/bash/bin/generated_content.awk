#! /usr/bin/awk -f

BEGIN	{
  for (i = 0; i < ARGC; ++i) {
    if (ARGV[i] ~ /(-h|--help)/) {
      usage()
      exit
    }
  }

  if (!begin) begin = "BEGIN - GENERATED CONTENT, DO NOT EDIT !!!"
  if (!end) end = "END - GENERATED CONTENT, DO NOT EDIT !!!"
  if (!action) action = "content"
  begin_found = 0
  end_found = 0
}
{
  # Print the beginning of the file
  if (action == "begin") {
    if (match($0, begin)) exit 0
    print $0
  # Print the end of the file
  } else if (action == "end") {
    if (end_found) print $0
    if (match($0, end)) end_found = 1
  # Print the content of the file between the beginning and the end
  } else if (action == "content") {
    if (match($0, end)) end_found = 1
    if (begin_found && !end_found) print $0
    if (match($0, begin)) begin_found = 1
  # Print the content
  } else if (action == "replace") {
    if (match($0, end)) end_found = 1
    if (!begin_found || (begin_found && end_found)) print $0
    if (match($0, begin)) {
      begin_found = 1
      if (content) print content
      else if (content_file) system("cat "content_file)
    }
  }
}
END	{
}
function usage() {
  print "Usage: generated_content [option] file..."
  print "Options are passed like this: -v option=value"
  print "Options:"
  print "\tbegin: define the regex to detect the begining of the generated bloc inside the file"
  print "\tend: define the regex to detect the end of the generated bloc inside the file"
  print "\taction:"
  print "\t\tbegin: it will display the beginning of the file (before the begin flag)"
  print "\t\tend: it will display the end of the file (after the end flag)"
  print "\t\tcontent: it will display the generated content of the file (between between flag and end flag)"
  print "\t\treplace: it will display the full file but will replace its generated content by either the content option is set either the content of the file given by the option content_file if set either nothing"
  print "\tcontent: content to use when option action=replace"
  print "\tcontent_file: path to the file to use when option action=replace"
  print "\neg. generated_content -v begin='BEGIN .*' -v end='END' -v action=begin ~/.bashrc"
  print "eg. generated_content -v action=replace -v content=\"$(generated_content -v action=content .bashrc)\" ~/.bashrc"
}
