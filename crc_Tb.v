`timescale 10ns/1ns

module crc_Tb();



/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter DATA_WIDTH_Tb = 8 ;
parameter Clock_PERIOD = 10 ;
parameter Test_Cases = 10 ;


/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg		CLK_Tb;
reg		RST_Tb;
reg		DATA_Tb;
reg		ACTIVE_Tb;
wire	Valid_Tb;
wire	CRC_Tb;

/////////////////////////////////////////////////////////
///////////////// Loops Variables ///////////////////////
/////////////////////////////////////////////////////////

integer                       Test_Case_no ;


/////////////////////////////////////////////////////////
/////////////////////// Memories ////////////////////////
/////////////////////////////////////////////////////////

reg    [DATA_WIDTH_Tb-1:0]   Test_Seeds   [Test_Cases-1:0] ;
reg    [DATA_WIDTH_Tb-1:0]   Expec_Outs   [Test_Cases-1:0] ;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial	begin

// System Functions
 $dumpfile("CRC_DUMP.vcd") ;       
 $dumpvars; 
 
 // Read Input Files
 $readmemh("DATA_h.txt", Test_Seeds);
 $readmemh("Expec_Out_h.txt", Expec_Outs);


 // initialization
 initialize() ;

 //reset
 reset();


 // Test Cases
 for (Test_Case_no=0;Test_Case_no<Test_Cases;Test_Case_no=Test_Case_no+1)
  begin
   Do_CRC(Test_Seeds[Test_Case_no]) ;                       // Do_CRC_operation
   Check_Out(Expec_Outs[Test_Case_no],Test_Case_no) ;       // Check Output response
	reset();
  end

 #1
 $finish ;

end









////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
begin
	CLK_Tb = 0;
	ACTIVE_Tb = 0;
end
endtask



/////////////// 	reset	 //////////////////

task reset ;
begin
	RST_Tb = 1;
	#(Clock_PERIOD);
	RST_Tb = 0;
	#(Clock_PERIOD);
	RST_Tb = 1;
end
endtask


/////////////// 	Do CRC	 //////////////////

task Do_CRC;
	input [DATA_WIDTH_Tb-1:0] IN_SEED;

	integer i;
begin
	//#(Clock_PERIOD/2);
	ACTIVE_Tb = 1;
	for(i=0;i<DATA_WIDTH_Tb;i=i+1)
		begin
		DATA_Tb = IN_SEED[i];
		#(Clock_PERIOD);
		end
	ACTIVE_Tb = 0;
end

endtask



/////////////// 	Check OUT	 //////////////////

task Check_Out;
	input	[DATA_WIDTH_Tb-1:0] expec_out;
	input 	[3:0]				Oper_no;
	
	integer i ;
	reg    [DATA_WIDTH_Tb-1:0]     gener_out ;

begin	
	@(posedge Valid_Tb)
	for(i=0; i<DATA_WIDTH_Tb; i=i+1)
	begin
    	#(Clock_PERIOD);
	gener_out[i] = CRC_Tb ;
	end
   if(gener_out == expec_out) 
    begin
     $display("Test Case %d is succeeded",Oper_no);
    end
	else
    begin
     $display("Test Case %d is failed", Oper_no);
    end

end

endtask


////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////

always #(Clock_PERIOD/2)  CLK_Tb = ~CLK_Tb ;



////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////

crc #(.DATA_WIDTH(DATA_WIDTH_Tb) )  DUT (
	.DATA(DATA_Tb),
	.ACTIVE(ACTIVE_Tb),
	.CLK(CLK_Tb),
	.RST(RST_Tb),
	.CRC(CRC_Tb),
	.Valid(Valid_Tb)
);


endmodule
