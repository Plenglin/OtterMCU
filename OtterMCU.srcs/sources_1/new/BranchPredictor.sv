interface BranchPredictor(
    input clk,
    input reset,
    input [31:0] pc,
    input is_branch,
    input func3_t branch_type,
    output should_branch
);
endinterface