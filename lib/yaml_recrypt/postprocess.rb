module YamlRecrypt
  module PostProcess

    def self.postprocess(filename)
      lines = File.readlines(filename)
      fix_encoding(lines)
      File.open(filename, "w") do |f|
        f.puts(lines)
      end
    end

    def self.fix_encoding(raw_lines)
      i = 0;
      while i < raw_lines.size
        if i+1 < raw_lines.size
          # we have to lookahead 1 line so make sure we're not already at the EOF
          # if we scan one line ahead
          if raw_lines[i+1] =~ /ENC\[PKCS7/
            # this is an eyaml block, change the pipe dash to be a chevron if needed
            if ! (raw_lines[i] =~ />/)
              # needs fix
              raw_lines[i] = raw_lines[i].gsub(/\|-/,'>')
            end
          end
        end
        i += 1
      end

      # adjustments were made in-place so void
    end

  end
end
