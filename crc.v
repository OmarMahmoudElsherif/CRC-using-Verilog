module crc #(
	parameter	DATA_WIDTH = 8 		//default value
)

(
	input			DATA,
	input			ACTIVE,
	input			CLK,
	input			RST,
	output	reg		CRC,
	//input 			OUT_ENN,
	output	reg		Valid
);

// 8 bit LFSR
reg			[7:0]	LFSR;
// Taps parameters
parameter	[7:0]	Taps = 'b0100_0100;			// '1'= means input XOR with feedback, '0' means input directly in.

// iterator
integer i;

//input Seed
localparam	[7:0]	SEED = 'hD8;

// feedback
wire	Feedback;
assign  Feedback = DATA ^ LFSR [0] ;

//Counter 
reg	[5:0]	Counter = 0;		// as data size vary from 1byte(8bits) to 4bytes(32bits)
reg			Counter_done = 0;


//Sequential Always
always@(posedge CLK,negedge RST) begin
	if(!RST)	begin
		Valid <= 'b0;
		LFSR  <= SEED;
		Counter <= 'b0;
		Counter_done <= 'b1;
	end
	else if(ACTIVE)		begin
		Valid	<=	1'b0;
		Counter <= 'b0;
		Counter_done <= 'b0;
		//opreation
		LFSR[7] <= Feedback;
		for(i=6;i>=0;i=i-1) begin
			if(Taps[i]==1)
				LFSR[i]	<=	LFSR[i+1] ^ Feedback;
			else
				LFSR[i] <= LFSR[i+1];
		end
	end
	else if( !Counter_done)	begin
			{LFSR[6:0],CRC} <= LFSR ;  
			Valid <= 1'b1;
			
			if(Counter==DATA_WIDTH)
			begin
				Counter_done <= 'b1;
				Valid <= 'b0;
			end
			else
				Counter	<=	Counter +'b1;
	
		end
	else	
		Valid	<=	1'b0;

end



endmodule