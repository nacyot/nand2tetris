@256
D=A
@SP
M=D
// Parser::Call call Sys.init 0
@CALL.0
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@0
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.init
0;JMP
(CALL.0)
// Parser::Function function Main.fibonacci 0
(Main.fibonacci)

// Parser::Push push argument 0
          @ARG
          D=M
          @0
          D=D+A
          @R15
          M=D

@R15
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Parser::PushConstant push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// Parser::ConditionOp lt
@SP
M=M-1
@SP
A=M
D=M
@R15
M=D
@SP
M=M-1
@SP
A=M
D=M
@R15
D=D-M
@LT.0
D;JLT
@SP
A=M
D=0
@LTend.0
0;JMP
(LT.0)
@SP
A=M
D=-1
(LTend.0)
@SP
A=M
M=D
@SP
M=M+1
// Parser::IfGoto if-goto IF_TRUE
@SP
M=M-1
@SP
A=M
D=M
@IF_TRUE
D;JNE
// Parser::Goto goto IF_FALSE
@IF_FALSE
0;JMP
// Parser::Label label IF_TRUE
(IF_TRUE)
// Parser::Push push argument 0
          @ARG
          D=M
          @0
          D=D+A
          @R15
          M=D

@R15
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Parser::Return return
@LCL
D=M
@R13
M=D
@LCL
D=M
@5
A=D-A
D=M
@R14
M=D
@SP
M=M-1
@SP
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M
D=D+1
@SP
M=D
@R13
M=M-1
@R13
A=M
D=M
@THAT
M=D
@R13
M=M-1
@R13
A=M
D=M
@THIS
M=D
@R13
M=M-1
@R13
A=M
D=M
@ARG
M=D
@R13
M=M-1
@R13
A=M
D=M
@LCL
M=D
@R13
M=M-1
@R14
A=M
0;JMP
// Parser::Label label IF_FALSE
(IF_FALSE)
// Parser::Push push argument 0
          @ARG
          D=M
          @0
          D=D+A
          @R15
          M=D

@R15
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Parser::PushConstant push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// Parser::BinaryOp sub
@SP
M=M-1
@SP
A=M
D=M
@R15
M=D
@SP
M=M-1
@SP
A=M
D=M
@R15
D=D-M
@SP
A=M
M=D
@SP
M=M+1
// Parser::Call call Main.fibonacci 1
@CALL.1
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@1
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Main.fibonacci
0;JMP
(CALL.1)
// Parser::Push push argument 0
          @ARG
          D=M
          @0
          D=D+A
          @R15
          M=D

@R15
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Parser::PushConstant push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// Parser::BinaryOp sub
@SP
M=M-1
@SP
A=M
D=M
@R15
M=D
@SP
M=M-1
@SP
A=M
D=M
@R15
D=D-M
@SP
A=M
M=D
@SP
M=M+1
// Parser::Call call Main.fibonacci 1
@CALL.2
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@1
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Main.fibonacci
0;JMP
(CALL.2)
// Parser::BinaryOp add
@SP
M=M-1
@SP
A=M
D=M
@R15
M=D
@SP
M=M-1
@SP
A=M
D=M
@R15
D=D+M
@SP
A=M
M=D
@SP
M=M+1
// Parser::Return return
@LCL
D=M
@R13
M=D
@LCL
D=M
@5
A=D-A
D=M
@R14
M=D
@SP
M=M-1
@SP
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M
D=D+1
@SP
M=D
@R13
M=M-1
@R13
A=M
D=M
@THAT
M=D
@R13
M=M-1
@R13
A=M
D=M
@THIS
M=D
@R13
M=M-1
@R13
A=M
D=M
@ARG
M=D
@R13
M=M-1
@R13
A=M
D=M
@LCL
M=D
@R13
M=M-1
@R14
A=M
0;JMP
// Parser::Function function Sys.init 0
(Sys.init)

// Parser::PushConstant push constant 4
@4
D=A
@SP
A=M
M=D
@SP
M=M+1
// Parser::Call call Main.fibonacci 1
@CALL.3
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@1
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Main.fibonacci
0;JMP
(CALL.3)
// Parser::Label label WHILE
(WHILE)
// Parser::Goto goto WHILE
@WHILE
0;JMP
