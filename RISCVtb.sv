`timescale 1ns/1ps

module riscv_core_tb;

    reg clk;
    reg rst;

    riscv_core dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        $dumpfile("riscv_core.vcd");
        $dumpvars(0, riscv_core_tb);

        rst = 1;

        #20;
        rst = 0;

        #200;

        $display("=================================");
        $display("REGISTER VALUES");
        $display("=================================");

        $display("x1 = %0d", dut.u_reg_file.regs[1]);
        $display("x2 = %0d", dut.u_reg_file.regs[2]);
        $display("x3 = %0d", dut.u_reg_file.regs[3]);
        $display("x4 = %0d", dut.u_reg_file.regs[4]);
        $display("x5 = %0d", dut.u_reg_file.regs[5]);
        $display("x6 = %0d", dut.u_reg_file.regs[6]);
        $display("x7 = %0d", dut.u_reg_file.regs[7]);

        $display("=================================");

        if (
            dut.u_reg_file.regs[1] == 32'd5  &&
            dut.u_reg_file.regs[2] == 32'd10 &&
            dut.u_reg_file.regs[3] == 32'd15 &&
            dut.u_reg_file.regs[4] == 32'd5  &&
            dut.u_reg_file.regs[5] == 32'd0  &&
            dut.u_reg_file.regs[6] == 32'd15 &&
            dut.u_reg_file.regs[7] == 32'd1
        )
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;

    end

endmodule
