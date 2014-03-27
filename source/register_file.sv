 
`include "register_file_if.vh"

module register_file
(
	input CLK, nRST,
	register_file_if.rf rfif
);

import cpu_types_pkg::word_t;
word_t [31:0] register;

always_ff @(posedge CLK or negedge nRST) begin
	if(!nRST)
	begin
		register <= '0;
	end
	else if(rfif.WEN)
	begin
		register[rfif.wsel] <= (rfif.wsel == 0) ? '0 : rfif.wdat;
	end
end

assign rfif.rdat1 = register[rfif.rsel1];
assign rfif.rdat2 = register[rfif.rsel2];

endmodule
