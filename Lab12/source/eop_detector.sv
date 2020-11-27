module eop_detector (
    input wire d_plus,
    input wire d_minus,
    output wire eop
);
    assign eop = (!d_plus) && (!d_minus);

endmodule