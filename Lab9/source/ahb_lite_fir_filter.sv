module ahb_lite_fir_filter (
    input wire clk,
    input wire n_rst,
    input wire hsel,
    input wire hsize,
    input wire [3:0] haddr,
    input wire [1:0] htrans,
    input wire hwrite,
    input wire [15:0] hwdata,
    output wire [15:0] hrdata,
    output wire hresp
);

    wire [15:0] fir_out, sample_data, fir_coefficient;
    wire err, data_ready, modwait, load_coeff, new_coefficient_set, one_k_samples;
    wire [1:0] coefficient_num;

    ahb_lite_slave slave (
        .clk(clk),
        .n_rst(n_rst),
        .sample_data(sample_data),
        .data_ready(data_ready),
        .new_coefficient_set(new_coefficient_set),
        .fir_coefficient(fir_coefficient),
        .modwait(modwait),
        .fir_out(fir_out),
        .err(err),
        .hsel(hsel),
        .haddr(haddr),
        .hsize(hsize),
        .htrans(htrans),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .hrdata(hrdata),
        .hresp(hresp),
        .coefficient_num(coefficient_num)
    );

    coefficient_loader load (
        .clk(clk),
        .n_reset(n_rst),
        .new_coefficient_set(new_coefficient_set),
        .modwait(modwait),
        .load_coeff(load_coeff),
        .coefficient_num(coefficient_num)
    );

    fir_filter fir (
        .clk(clk),
        .n_reset(n_rst),
        .sample_data(sample_data),
        .data_ready(data_ready),
        .fir_coefficient(fir_coefficient),
        .load_coeff(load_coeff),
        .one_k_samples(one_k_samples),
        .modwait(modwait),
        .fir_out(fir_out),
        .err(err)
    );
endmodule