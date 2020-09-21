onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color gold /tb_adder_16bit/tb_test_case_num
add wave -noupdate -color gold /tb_adder_16bit/tb_test_case
add wave -noupdate -color gold /tb_adder_16bit/tb_test_case_stage
add wave -noupdate -color gold /tb_adder_16bit/tb_test_case_err
add wave -noupdate -divider {DUT Signal}
add wave -noupdate -color purple -radix unsigned /tb_adder_16bit/tb_a
add wave -noupdate -color purple -radix unsigned /tb_adder_16bit/tb_b
add wave -noupdate -color purple -radix unsigned /tb_adder_16bit/tb_carry_in
add wave -noupdate -expand -group Sum -color red -radix unsigned /tb_adder_16bit/tb_sum
add wave -noupdate -expand -group Sum -color blue -radix unsigned /tb_adder_16bit/tb_expected_sum
add wave -noupdate -expand -group Overflow -color red -radix unsigned /tb_adder_16bit/tb_overflow
add wave -noupdate -expand -group Overflow -color blue -radix unsigned /tb_adder_16bit/tb_expected_overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {220297 ps} 0} {{Cursor 2} {199035 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 246
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {391439 ps} {610977 ps}
