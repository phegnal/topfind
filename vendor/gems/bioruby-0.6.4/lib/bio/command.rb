#
# bio/command.rb - useful methods for external command execution
#
#   Copyright (C) 2003-2005 GOTO Naohisa <ng@bioruby.org>
#   Copyright (C) 2004 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: command.rb,v 1.1 2005/08/16 09:38:34 ngoto Exp $
#

require 'open3'

module Bio
module Command
module Tools

  UNSAFE_CHARS_UNIX   = /[^A-Za-z0-9\_\-\.\:\,\/\@\x1b\x80-\xfe]/n
  QUOTE_CHARS_WINDOWS = /[^A-Za-z0-9\_\-\.\:\,\/\@\\]/n
  UNESCAPABLE_CHARS   = /[\x00-\x08\x10-\x1a\x1c-\x1f\x7f\xff]/n

  #module_function
  private

  def escape_shell_windows(str)
    str = str.to_s
    raise 'cannot escape control characters' if UNESCAPABLE_CHARS =~ str
    if QUOTE_CHARS_WINDOWS =~ str then
      '"' + str.gsub(/\"/, '""') + '"'
    else
      String.new(str)
    end
  end

  def escape_shell_unix(str)
    str = str.to_s
    raise 'cannot escape control characters' if UNESCAPABLE_CHARS =~ str
    str.gsub(UNSAFE_CHARS_UNIX) { |x| "\\#{x}" }
  end

  def escape_shell(str)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      escape_shell_windows(str)
    else
      escape_shell_unix(str)
    end
  end

  def make_command_line(ary)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      make_command_line_windows(ary)
    else
      make_command_line_unix(ary)
    end
  end

  def make_command_line_windows(ary)
    ary.collect { |str| escape_shell_windows(str) }.join(" ")
  end

  def make_command_line_unix(ary)
    ary.collect { |str| escape_shell_unix(str) }.join(" ")
  end

  def call_command_local(cmd, query = nil, &block)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      call_command_local_popen(cmd, query, &block)
    else
      call_command_local_open3(cmd, query, &block)
    end
  end

  def call_command_local_popen(cmd, query = nil)
    str = make_command_line(cmd)
    IO.popen(str, "w+") do |io|
      if block_given? then
        io.sync = true
        yield io, io
      else
        io.sync = true
        io.print query if query
        io.close_write
        io.read
      end
    end
  end

  def call_command_local_open3(cmd, query = nil)
    cmd = cmd.collect { |x| x.to_s }
    Open3.popen3(*cmd) do |pin, pout, perr|
      perr.sync = true
      t = Thread.start { @errorlog = perr.read }
      if block_given? then
        yield pin, pout
      else
        begin
          pin.print query if query
          pin.close
          output = pout.read
        ensure
          t.join
        end
        output
      end
    end
  end

  attr_reader :errorlog
  public :errorlog

end #module Tools
end #module Command
end # module Bio


=begin

= Bio::Command

= Bio::Command::Tools

 Bio::Command::Tools is a collection of useful methods for execution
 of external commands or web applications. Any wrapper class for
 applications shall include this class. Note that all methods below
 are private except for some methods.

--- Bio::Command::Tools#escape_shell(str)

      Escape special characters in command line string.

--- Bio::Command::Tools#escape_shell_unix(str)

      Escape special characters in command line string for UNIX shells.

--- Bio::Command::Tools#escape_shell_windows(str)

      Escape special characters in command line string for cmd.exe on Windows.

--- Bio::Command::Tools#make_command_line(ary)

      Generate command line string with special characters escaped.

--- Bio::Command::Tools#make_command_line_unix(ary)

      Generate command line string with special characters escaped
      for UNIX shells.

--- Bio::Command::Tools#make_command_line_windows(ary)

      Generate command line string with special characters escaped
      for cmd.exe on Windows.

--- Bio::Command::Tools#exec_command_local(cmd, query = nil)
--- Bio::Command::Tools#exec_command_local(cmd) {|inn, out| ... }

      Executes the program.  Automatically select popen for Windows
      environment and open3 for the others.

      If block is given, yield the block with input and output IO objects.
      Note that in some platform, inn and out are the same object.
      Please be careful to do inn.close and out.close.

--- Bio::Command::Tools#exec_command_local_popen(cmd, query = nil)
--- Bio::Command::Tools#exec_command_local_popen(cmd) {|io, io| ... }

      Executes the program via IO.popen for OS which doesn't support
      fork.
      If block is given, yield the block with IO objects.
      The two objects are the same because of limitation of IO.popen.

--- Bio::Command::Tools#exec_command_local_open3(cmd, query = nil)
--- Bio::Command::Tools#exec_command_local_open3(cmd) {|inn, out| ... }

      Executes the program via Open3.popen3
      If block is given, yield the block with input and output IO objects.

      From the view point of security, this method is recommended
      rather than exec_local_popen.

--- Bio::Command::Tools#errorlog

      Shows the latest stderr of the program execution.
      Note that this method may be thread unsafe.

=end
