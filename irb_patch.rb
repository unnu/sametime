require 'irb'

class IO
  # Read a line without blocking. If there isn't a line to be read, return
  # nil.
  def readline_nonblock
    line = ''

    begin
      char = read_nonblock 1 # A larger read would surely be more efficient.
      while char != "\n"
        line += char
        char = read_nonblock 1
      end
    rescue Errno::EAGAIN
      sleep 0.1
      retry
    rescue EOFError
      line = nil
    end

    line
  end

  # Yield once for every line recieved from readline_nonblocking, until it
  # returns nil.
  def each_nonblock
    line = readline_nonblock
    while not line.nil?
      yield line
      line = readline_nonblock
    end
  end
end

module IRB
    class ReadlineInputMethod < InputMethod

      def gets
        #Readline.input = @stdin
        Readline.output = @stdout
        if l = @stdin.readline_nonblock
          HISTORY.push(l) if !l.empty?
          @line[@line_no += 1] = l + "\n"
        else
          @eof = true
          l
        end
      end
    end
end