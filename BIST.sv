//
// behavioral model BIST FSM
//

module BISTFSM(	input ClK,
				input Clear,
				input BIST_Start,
				input Data_Rdy,
				input bit [7:0]Rx_Data,
				output reg BIST_Mode,
				output bit [7:0]Tx_Data,
				output reg Transmit_Start,
				output bit [2:0]BIST_Error,
				output reg BIST_Busy);

//input ClK, Clear, BIST_Start, Data_Rdy, [7:0]Rx_Data;
//output BIST_Mode, [7:0]Tx_Data, Transmit_Start, [2:0]BIST_Error, BIST_Busy;
//reg BIST_Mode, Tx_Data[7:0], Transmit_Start, [2:0]BIST_Error, BIST_Busy;

parameter ON  = 1'b1;
parameter OFF = 1'b0;

// define states using same names and state assignments as state diagram and table
// Using one-hot method, we have one bit per state

typedef enum logic [3:0] {
	READY  		= 4'b0001,
	BIST_ACTIVE	= 4'b0010,
	BIST_LOOP 	= 4'b0100,
	BIST_DONE  	= 4'b1000} FSMState;
	
FSMState State, NextState;


//
// Update state or reset on every + clock edge
//

always_ff @(posedge ClK)
begin
if (Clear)
	State <= READY;
else
	State <= NextState;
end


//
// Outputs depend only upon state (Moore machine)
//

always_comb
begin

unique case (State)
	READY:
		begin
		//{BIST_Mode, Tx_Data[7:0], Transmit_Start, BIST_Error[2:0], BIST_Busy} = 5'b00000;
		BIST_Mode = 0;
		Tx_Data[7:0] = 8'b00000000;
		Transmit_Start = 0;
		BIST_Error[2:0] = 3'b000;
		BIST_Busy = 0;	
		end

	BIST_ACTIVE:
		begin
		//{BIST_Mode, Tx_Data[7:0], Transmit_Start, BIST_Error[2:0], BIST_Busy} = 5'b10001;
		BIST_Mode = 0;
		Tx_Data[7:0] = 8'b00000000;
		Transmit_Start = 0;
		BIST_Error[2:0] = 3'b000;
		BIST_Busy = 1;
		end

	BIST_LOOP:
		begin
		//{BIST_Mode, Tx_Data[7:0], Transmit_Start, BIST_Error[2:0], BIST_Busy} = 5'b10101;
		BIST_Mode = 1;
		Tx_Data[7:0] = 8'b00000000;
		Transmit_Start = 1;
		BIST_Error[2:0] = 3'b000;
		BIST_Busy = 1;
		end

	BIST_DONE:
		begin
		//{BIST_Mode, Tx_Data[7:0], Transmit_Start, BIST_Error[2:0], BIST_Busy} = 5'b00000;
		BIST_Mode = 0;
		Tx_Data[7:0] = 8'b00000000;
		Transmit_Start = 0;
		BIST_Error[2:0] = 3'b101;
		BIST_Busy = 0;
		end

endcase
end



//
// Next state generation logic
//

always_comb
begin
unique case (State)
	READY:
		begin
		if (BIST_Start)
			NextState = BIST_ACTIVE;
		else
			NextState = READY;
		end

	BIST_ACTIVE:
		begin
			NextState = BIST_LOOP;
		end

	BIST_LOOP:
		begin
		if (Data_Rdy)
			NextState = BIST_DONE;
		else
			NextState = BIST_LOOP;
		end

	BIST_DONE:
		begin
			NextState = READY;
		end

endcase
end


endmodule

