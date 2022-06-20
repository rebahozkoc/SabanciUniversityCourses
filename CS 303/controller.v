module controller(
    input c1khz,
    input rst,
    input beginn, 
    input reset,
    input zero,
    input endd,
    output load,
    output start,
    output countdown
    );

    reg [1:0] state = 2'b00;
  localparam [1:0] // 4 states are required for Moore
    zeroState = 2'b00, // nothing started state
    oneState = 2'b01,  // counter start state
    twoState = 2'b10,  // counter end state
    threeState = 2'b11; // start again state
  

  reg countTemp;
  assign countdown= (endd && ~(state == zeroState));
  reg startTemp;
  assign start = startTemp;
  reg loadTemp;
	


assign load = reset;

always @(posedge c1khz, negedge rst)
begin
  if(~rst)
  begin
  state <= zeroState;
  end
  else if (beginn && ~zero)
  begin
  state <= oneState;
  end
  else if (reset)
  begin
  state <= zeroState;
  end
  else if (zero)
  begin
  state <= zeroState;
  end
  case(state)
	zeroState: // nothing started state
	begin
	countTemp <= 0;
	end
	oneState:
	begin
	startTemp <= 1;

	state <= twoState;
	end
	twoState:
	begin
	startTemp <= 0;
	if (endd)
	state <= oneState;
	end
	threeState:
	begin
	end
     
  endcase



end // always


 
endmodule