#!/usr/bin/env ruby -w

class String
  def number_instructions
    i = -1
    self.lines.map { |s|
      case s
      when /^\/\/\/+/ then
        "   #{s.chomp}"
      when /^\/\/ / then
        "\n#{s}"
      when /^\(/ then
        s.chomp
      else
        if ENV["DEBUG"] then
          i += 1
          "%-21s // %d" % [s.chomp, i]
        else
          s.chomp
        end
      end
    }.join "\n"
  end
end

class Compiler
  def self.run paths
    compiler = Compiler.new

    result = paths.map { |path|
      compiler.file_name = File.basename path, ".vm"

      File.open path do |file|
        compiler.assemble file
      end
    }

    result.unshift Init.new if paths.size > 1

    puts postprocess result
  end

  def self.postprocess result
    result.flatten.compact.join("\n").gsub(/^(?![\/\(])/, '   ').number_instructions
  end

  attr_accessor :file_name

  SEGMENTS = %w(argument local static constant this that pointer temp).join "|"
  OPS      = %w(add sub neg eq gt lt and or not).join "|"

  def initialize
    self.file_name = "unknown"
  end

  def assemble io
    io.each_line.map { |line|
      case line.strip.sub(%r%\s*//.*%, '')
      when "" then
        nil
      when /^push (#{SEGMENTS}) (\d+)/ then
        Push.new $1, $2.to_i, file_name
      when /^pop (#{SEGMENTS}) (\d+)/ then
        Pop.new $1, $2.to_i, file_name
      when /^(#{OPS})$/ then
        Op.new $1
      when /^label (\S+)$/ then
        Label.new $1
      when /^if-goto (\S+)$/ then
        IfGoto.new $1
      when /^goto (\S+)$/ then
        Goto.new $1
      when /^function (\S+) (\d+)$/ then
        Function.new $1, $2.to_i
      when /^call (\S+) (\d+)$/ then
        Call.new $1, $2.to_i
      when /^return$/ then
        Return.new
      else
        raise "Unparsed: #{line.inspect}"
      end
    }
  end

  module Asmable
    def asm *instructions
      instructions
    end

    def assemble(*instructions)
      instructions.flatten.compact.join "\n"
    end
  end

  module Stackable
    @@next_num = Hash.new 0

    def next_num name
      n = @@next_num[name] += 1
      "#{name}.#{n}"
    end

    def pop dest
      asm "@SP", "AM=M-1", "#{dest}=M"
    end

    def push_d deref = "AM=M+1", val="D"
      #   deref_sp      dec_ptr  write
      asm "@SP", deref, "A=A-1", "M=#{val}"
    end

    def store_d loc
      asm loc, "M=D"
    end

    def store_d! loc
      asm loc, "A=M", "M=D"
    end
  end

  class Init
    include Asmable
    include Stackable

    def comment
      "// bootstrap"
    end

    def to_s
      fuck = next_num "FUCK_IT_BROKE"

      assemble(comment,
               "/// SP = 256",
               "@256", "D=A", store_d("@SP"),

               "/// set THIS=THAT=LCL=ARG=-1 to force error if used as pointer",
               "D=-1",
               store_d("@THIS"), store_d("@THAT"),
               store_d("@LCL"),  store_d("@ARG"),

               Call.new("Sys.init", 0),
               Label.new(fuck),
               Goto.new(fuck))
    end
  end

  class StackThingy < Struct.new :segment, :offset, :file_name
    include Asmable
    include Stackable

    def comment
      asm "// #{name} #{segment} #{offset}"
    end

    def name
      self.class.name.split(/::/).last.downcase
    end

    def dereference name
      case offset
      when 0 then
        asm "@#{name}", "A=M"
      when 1 then
        asm "@#{name}", "A=M+1"
      else
        asm "@#{name}", "D=M", "@#{offset}", "A=A+D"
      end
    end

    def constant
      asm "@#{offset}"
    end

    def self.def_deref name, slot
      define_method name do dereference slot end
    end

    def_deref :local,    "LCL"
    def_deref :argument, "ARG"
    def_deref :this,     "THIS"
    def_deref :that,     "THAT"

    def temp
      asm "@R#{offset + 5}"
    end

    def static
      asm "@#{file_name}.#{offset}"
    end

    def pointer
      off = "A=A+1" if offset != 0
      asm "@THIS", off
    end
  end

  class Push < StackThingy
    def store
      asm segment == "constant" ? "D=A" : "D=M"
    end

    def to_s
      assemble(comment,
               send(segment),
               store,
               push_d)
    end
  end

  class Pop < StackThingy
    def temp_store reg
      asm store_d(reg), yield, reg, "A=M"
    end

    def store
      asm "D=A"
    end

    def to_s
      assemble(comment,
               send(segment),
               store,
               temp_store("@R15") do
                 pop "D"
               end,
               asm("M=D"))
    end
  end

  class Op < Struct.new :msg
    include Asmable
    include Stackable

    def comment
      asm "// #{msg}"
    end

    def push_d
      super "A=M" unless %w[not neg].include? msg
    end

    def to_s
      assemble(comment,
               send(msg), # perform whatever operation, put into D
               push_d)
    end

    def binary *instructions
      asm pop(:D), "A=A-1", "A=M", instructions
    end

    def unary *instructions
      asm "@SP", "A=M-1", *instructions
    end

    def binary_test test
      addr = next_num test
      binary("D=A-D",
             "@#{addr}",
             "D;#{test}",
             "D=0",
             Goto.new("#{addr}.done", :none),
             Label.new(addr, :internal),
             "D=-1",
             Label.new("#{addr}.done", :internal))
    end

    def neg; unary "M=-M";      end
    def not; unary "M=!M";      end

    def add; binary "D=A+D";    end
    def and; binary "D=A&D";    end
    def or;  binary "D=A|D";    end
    def sub; binary "D=A-D";    end

    def eq;  binary_test "JEQ"; end
    def gt;  binary_test "JGT"; end
    def lt;  binary_test "JLT"; end
  end

  class Label < Struct.new :name, :internal
    include Asmable

    def initialize name, internal=false
      super
    end

    def comment
      return if internal
      asm "// label #{name}"
    end

    def to_s
      assemble(comment,
               asm("(#{name})"))
    end
  end

  class IfGoto < Struct.new :name
    include Asmable
    include Stackable

    def to_s
      assemble pop(:D), "@#{name}", "D;JNE"
    end
  end

  class Goto < Struct.new :name, :internal
    include Asmable

    def initialize name, internal=false
      super
    end

    def comment
      return if internal == :none
      comment = internal ? "///" : "//"
      "#{comment} goto @#{name}"
    end

    def to_s
      assemble comment, "@#{name}", "0;JMP"
    end
  end

  class Function < Struct.new :name, :size
    include Asmable
    include Stackable

    def comment
      asm "// function #{name} #{size}"
    end

    def push_locals
      case size
      when 0 then
      when 1, 2 then # 4n=5+2n == 2n=5 == n=2.5
        asm [push_d("AM=M+1", "0")] * size
      else
        asm "@#{size}", "D=A", "@SP", "AM=M+D", "A=A-D", ["M=0", "A=A+1"] * size
      end
    end

    def to_s
      assemble comment, Label.new(name, :internal), push_locals
    end
  end

  class Return
    include Asmable
    include Stackable

    def comment
      "// return"
    end

    def store_frame arg, off
      asm("/// #{arg} = *(FRAME-#{off})",
          "@#{off}", "D=A", "@R14", "A=M-D", "D=M", store_d(arg))
    end

    def decrement_and_store_frame arg, off
      asm("/// #{arg} = *(FRAME-#{off})",
          "@R14", "AM=M-1", "D=M", store_d(arg))
    end

    def to_s
      assemble(comment,
               "/// FRAME = LCL",
               "@LCL", "D=M", store_d("@R14"),

               store_frame("@R13", 5),

               "/// *ARG = pop()",
               pop(:D), store_d!("@ARG"),

               "/// SP = ARG+1",
               "@ARG", "D=M+1", store_d("@SP"),

               decrement_and_store_frame("@THAT", 1),
               decrement_and_store_frame("@THIS", 2),
               decrement_and_store_frame("@ARG", 3),
               decrement_and_store_frame("@LCL", 4),

               "/// goto RET",
               "@R13", "A=M", "0;JMP"
      )
    end
  end

  class Call < Struct.new :name, :size
    include Asmable
    include Stackable

    def comment
      asm "// call #{name} #{size}"
    end

    def push name, loc="M"
      asm "/// push #{name}", name, "D=#{loc}", push_d
    end

    def set dest, *instructions
      asm instructions + store_d(dest)
    end

    def to_s
      addr = next_num "return"
      assemble(comment,
               push("@#{addr}", "A"),
               push("@LCL"),
               push("@ARG"),
               push("@THIS"),
               push("@THAT"),
               set("@ARG", "/// ARG = SP-#{size}-5",
                   "@#{size + 5}", "D=A", "@SP", "D=M-D"),
               set("@LCL", "/// LCL = SP",
                   "@SP", "D=M"),
               Goto.new(name, :internal),
               Label.new(addr, :internal))
    end
  end
end

Compiler.run ARGV if $0 == __FILE__
