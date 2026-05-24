testbench code

timescale 1ns/1ps

// ALU


module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = (a < b) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule



// CONTROL UNIT

module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src,
    output reg [1:0]  alu_op
);

    always @(*) begin

        reg_write = 0;
        alu_src   = 0;
        alu_op    = 2'b00;

        case(opcode)

            7'b0110011: begin
                reg_write = 1;
                alu_src   = 0;
                alu_op    = 2'b10;
            end

            7'b0010011: begin
                reg_write = 1;
                alu_src   = 1;
                alu_op    = 2'b11;
            end

        endcase
    end

endmodule



// ALU CONTROL


module alu_control (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7_5,
    output reg [3:0]  alu_ctrl
);

    always @(*) begin

        case(alu_op)

            2'b10: begin

                case({funct7_5, funct3})

                    4'b0000: alu_ctrl = 4'b0000;
                    4'b1000: alu_ctrl = 4'b0001;
                    4'b0111: alu_ctrl = 4'b0010;
                    4'b0110: alu_ctrl = 4'b0011;
                    4'b0010: alu_ctrl = 4'b0100;

                    default: alu_ctrl = 4'b0000;

                endcase

            end

            2'b11: begin

                case(funct3)

                    3'b000: alu_ctrl = 4'b0000;
                    3'b111: alu_ctrl = 4'b0010;
                    3'b110: alu_ctrl = 4'b0011;

                    default: alu_ctrl = 4'b0000;

                endcase

            end

            default: alu_ctrl = 4'b0000;

        endcase

    end

endmodule


// IMMEDIATE GENERATOR


module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm
);

    always @(*) begin

        case(instr[6:0])

            7'b0010011:
                imm = {{20{instr[31]}}, instr[31:20]};

            default:
                imm = 32'd0;

        endcase

    end

endmodule



// REGISTER FILE


module reg_file (

    input wire clk,
    input wire rst,
    input wire reg_write,

    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,

    input wire [31:0] write_data,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] regs [0:31];

    integer i;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            for(i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;

        end
        else begin

            if(reg_write && (rd != 0))
                regs[rd] <= write_data;

        end

    end

    assign read_data1 = (rs1 == 0) ? 32'd0 : regs[rs1];
    assign read_data2 = (rs2 == 0) ? 32'd0 : regs[rs2];

endmodule



// INSTRUCTION MEMORY


module instr_mem (

    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:63];

    initial begin

        // addi x1, x0, 5
        mem[0] = 32'h00500093;

        // addi x2, x0, 10
        mem[1] = 32'h00A00113;

        // add x3, x1, x2
        mem[2] = 32'h002081B3;

        // sub x4, x2, x1
        mem[3] = 32'h40110233;

        // and x5, x1, x2
        mem[4] = 32'h0020F2B3;

        // or x6, x1, x2
        mem[5] = 32'h0020E333;

        // slt x7, x1, x2
        mem[6] = 32'h0020A3B3;

    end

    assign instr = mem[addr[31:2]];

endmodule


// RISC-V CORE


module riscv_core (
    input wire clk,
    input wire rst
);

    reg [31:0] pc;

    wire [31:0] instr;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire       funct7_5;

    wire reg_write;
    wire alu_src;
    wire [1:0] alu_op;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] imm;

    wire [3:0] alu_ctrl;

    wire [31:0] alu_in2;
    wire [31:0] alu_result;

    wire zero_unused;

    instr_mem u_instr_mem (
        .addr(pc),
        .instr(instr)
    );

    assign opcode    = instr[6:0];
    assign rd        = instr[11:7];
    assign funct3    = instr[14:12];
    assign rs1       = instr[19:15];
    assign rs2       = instr[24:20];
    assign funct7_5  = instr[30];

    control_unit u_control_unit (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_op(alu_op)
    );

    reg_file u_reg_file (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(alu_result),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen u_imm_gen (
        .instr(instr),
        .imm(imm)
    );

    alu_control u_alu_control (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_ctrl(alu_ctrl)
    );

    assign alu_in2 = (alu_src) ? imm : read_data2;

    alu u_alu (
        .a(read_data1),
        .b(alu_in2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero_unused)
    );

    always @(posedge clk or posedge rst) begin

        if(rst)
            pc <= 32'd0;
        else
            pc <= pc + 32'd4;

    end

endmodule