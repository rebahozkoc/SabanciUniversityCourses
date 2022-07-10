module downcounter(
  input rst, c1khz,
  input count, load, 
  input [3:0] pm10,
  input [3:0] pm1,
  input [3:0] ps10,
  input [3:0] ps1,
  output reg [3:0] m10,
  output reg [3:0] m1,
  output reg [3:0] s10,
  output reg [3:0] s1,
  output zero);
    
  reg [0:0] zero_r = 1;
  assign zero = (zero_r==1);


    
  reg [3:0]min10;
  reg [3:0]min1;
  reg [3:0]sec10;
  reg [3:0]sec1;
  
  always @(posedge count, negedge rst, posedge load)
    begin
      if (~rst)
        begin
          min10 <= 0;
          min1 <= 0;
          sec10 <= 0;
          sec1 <= 0;
          zero_r <= 1;
        end

      else if (load == 1)
        begin
          if (pm10 > 9)
            begin
              min10 <= 9;
            end
          else
            begin
              min10 <= pm10;
            end
        
          if (pm1 > 9)
            begin
              min1 <= 9;
            end
          else
            begin
              min1 <= pm1;
            end

          if (ps10 > 5)
            begin
              sec10 <= 5;
            end
          else
            begin
              sec10 <= ps10;
            end
        
          if (ps1 > 9)
            begin
              sec1 <= 9;
            end
          else
            begin
              sec1 <= ps1;
            end

          zero_r <= 0;
        end

      else if (count == 1)
        begin
          if (sec1 != 0)
            begin
              sec1 <= sec1 - 1;
              zero_r <= 0;
            end
          else
            begin
              if (sec10 != 0)
                begin
                  sec10 <= sec10 - 1;
                  sec1 <= 9;
                  zero_r <= 0;
                end
              else
                begin
                  if (min1 != 0)
                    begin
                      min1 <= min1 -1;
                      sec10 <= 5;
                      sec1 <= 9;
                      zero_r <= 0;
                    end
                  else
                    begin
                      if (min10 != 0)
                        begin
                          min10 <= min10 - 1;
                          min1 <= 9;
                          sec10 <= 5;
                          sec1 <= 9;
                          zero_r <= 0;
                        end
                      else
                        begin
                          zero_r <= 1;
                        end
                    end
                end
            end
        end       
    end	    

always @(posedge c1khz)
begin     
   m10 <= min10;
   m1 <= min1;
   s10 <= sec10;
   s1 <= sec1;
end

endmodule