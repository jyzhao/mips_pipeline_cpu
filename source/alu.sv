module alu
(
	input logic [31:0] portA, portB,
	input logic [3:0] aluop,
	output logic [31:0] outPort,
	output logic negF, zerF, oveF
);

always_comb begin
	if     (aluop == 4'b0100) // AND
		outPort = portA & portB;
	else if(aluop == 4'b0101) // OR
		outPort = portA | portB;
	else if(aluop == 4'b0110) // XOR
		outPort = portA ^ portB;
	else if(aluop == 4'b0111) // NOR
		outPort = ~(portA | portB);
	else if(aluop == 4'b0000) // Logical Shift Left
		outPort = portA << portB;
	else if(aluop == 4'b0001) // Logical Shift Right
		outPort = portA >> portB;
	else if(aluop == 4'b0010) // add
		outPort = portA + portB;
	else if(aluop == 4'b0011) // subtract
		outPort = portA - portB;
	else if(aluop == 4'b1011) // Unsigned Set Less Than
		outPort = (portA < portB);
	else if(aluop == 4'b1010) // Signed Set Less Than
		outPort = ($signed(portA) < $signed(portB));
	else
		outPort = '0;
end

assign negF = outPort[31];
assign zerF = (outPort == 0);
assign oveF = (!portA[31] && !portB[31] && outPort[31]);

endmodule



/*
module alu(alu_if aif);

always_comb begin
	if     (aif.aluop == 4'b0100) // AND
		aif.outPort = aif.portA & aif.portB;
	else if(aif.aluop == 4'b0101) // OR
		aif.outPort = aif.portA | aif.portB;
	else if(aif.aluop == 4'b0110) // XOR
		aif.outPort = aif.portA ^ aif.portB;
	else if(aif.aluop == 4'b0111) // NOR
		aif.outPort = ~(aif.portA | aif.portB);
	else if(aif.aluop == 4'b0000) // Logical Shift Left
		aif.outPort = aif.portA << aif.portB;
	else if(aif.aluop == 4'b0001) // Logical Shift Right
		aif.outPort = aif.portA >> aif.portB;
	else if(aif.aluop == 4'b0010) // add
		aif.outPort = aif.portA + aif.portB;
	else if(aif.aluop == 4'b0011) // subtract
		aif.outPort = aif.portA - aif.portB;
	else if(aif.aluop == 4'b1011) // Unsigned Set Less Than
		aif.outPort = (aif.portA < aif.portB);
	else if(aif.aluop == 4'b1010) // Signed Set Less Than
		aif.outPort = ($signed(aif.portA) < $signed(aif.portB));
	else
		aif.outPort = '0;
end

assign aif.negF = aif.outPort[31];
assign aif.zerF = (aif.outPort == 0);
assign aif.oveF = (!aif.portA[31] && !aif.portB[31] && aif.outPort[31]);

endmodule
*/
