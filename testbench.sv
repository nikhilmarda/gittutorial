module TestBench;

reg ClK, Clear, BIST_Start, Data_Rdy;
bit [7:0]Rx_Data;
wire BIST_Mode, Transmit_Start, BIST_Busy;
bit  [2:0]BIST_Error;
bit [7:0]Tx_Data;

parameter TRUE   = 1'b1;
parameter FALSE  = 1'b0;
parameter CLOCK_CYCLE  = 20ns;
parameter CLOCK_WIDTH  = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS  = 2;

bit Visited[string];			// keep track of visited states

BISTFSM BFSM(ClK, Clear, BIST_Start, Data_Rdy, Rx_Data, BIST_Mode, Tx_Data, Transmit_Start, BIST_Error, BIST_Busy );

//
// set up monitor
//

initial
begin
$display("                Time , BIST_Start, Data_Rdy, Rx_Data, Tx_Data, State\n");
$monitor($time, "  %b     %b       %b     %b  %s", BIST_Start, Data_Rdy, Rx_Data, Tx_Data, BFSM.State.name);
end



//
// Create free running clock
//

initial
begin
ClK = FALSE;
forever #CLOCK_WIDTH ClK = ~ClK;
end


//
// Generate Clear signal for two cycles
//

initial
begin
Clear = TRUE;
repeat (IDLE_CLOCKS) @(negedge ClK);
Clear = FALSE;
end


//
// Keep track of states visited
//

always @(negedge ClK)
begin
Visited[BFSM.State.name] = 1;
end


//
// Generate stimulus after waiting for reset
//

initial
begin

@(negedge ClK); {BIST_Start, Data_Rdy, Rx_Data} = 10'b1000000000;   //   Next clock
repeat (4) @(negedge ClK);

@(negedge ClK); {BIST_Start, Data_Rdy, Rx_Data} = 10'b0100000000;   //  Next clock
repeat (4) @(negedge ClK);



BFSM.State = BFSM.State.first;
forever
  begin
  if (!Visited.exists(BFSM.State.name))
  	$display("Never entered state %s\n",BFSM.State.name);
  if (BFSM.State == BFSM.State.last) break;
  BFSM.State = BFSM.State.next;
  end

$stop;
end


endmodule

