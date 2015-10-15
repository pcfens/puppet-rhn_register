#
# command_args.rb
#
module Puppet::Parser::Functions
  newfunction(:command_args, :type => :rvalue, :doc => <<-EOS
Convert a hash into command line arguments.
    EOS
  ) do |arguments|

    # Validate the number of arguments.
    raise(Puppet::ParseError, "command_args(): Wrong number of arguments " +
          "given (#{arguments.size} for 1)") if arguments.size < 1

    # Validate the first argument.
    hash = arguments[0]
    if not hash.is_a?(Hash)
      raise(TypeError, "command_args(): The only argument must be a " +
            "hash, but a #{hash.class} was given.")
    end

    flag = arguments[1] if arguments[1]
    if flag
      unless flag.is_a?(String)
        raise(Puppet::ParseError, "command_args() second argument must be " +
              "string if provided, but a #{flag.class} was given.")
      end
    else
      flag = '--'
    end

    parameters = ""

    hash.map do |k,v|
      if v.is_a?(Array)
        v.each do |item|
          if item.is_a?(String) or item.is_a?(Numeric)
            parameters << flag + String(k) + '=' + String(item)
            parameters << ' '
          else
            raise(TypeError, "Arrays can only contain String and Numeric " +
                  "data types, but a #{item.class} was given.")
          end
        end
      elsif v.is_a?(String)
        parameters << flag + String(k) + '=' + String(v)
      elsif v.is_a?(TrueClass)
        parameters << flag + String(k)
      elsif v.is_a?(Numeric)
        parameters << flag + String(k) + '=' + String(v)
      else
        raise(TypeError, "Only strings, numerics, booleans, and arrays of " +
              "strings and numerics can be be used in command line arguments " +
              "but #{v.class} given.")
      end
      parameters << ' '
    end

    return parameters

  end
end

# vim: set ts=2 sw=2 et :
