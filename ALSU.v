module ALSU ( A , B , opcode , cin , serial_in , direction, 
red_op_A , red_op_B , bypass_A , bypass_B , clk , rst , 
out , leds );

  parameter INPUT_PRIORITY = "A";
  parameter FULL_ADDER = "ON";

  input [2:0] A , B , opcode;
  input cin , serial_in , direction , red_op_A , red_op_B , bypass_A , bypass_B , clk , rst ;
  output [5:0] out;
  output [15:0] leds;

  reg [15:0] leds_reg = 16'h00;
  reg [2:0] A_reg , B_reg , op_reg;
  reg cin_reg , serial_in_reg , direction_reg , red_op_A_reg , red_op_B_reg , bypass_A_reg , bypass_B_reg;
  reg [5:0] out_reg;
  reg [5:0] y;


  reg flag_red_A=0;
  reg flag_bypass_A=0;
  reg flag_red_B=0;
  reg flag_bypass_B=0;

  assign out = out_reg;
  assign leds = leds_reg;

always @ ( posedge clk , posedge rst ) begin
  if(rst) begin
    A_reg <= 0;
    B_reg <= 0;
    op_reg <=0;
    cin_reg <=0; 
    serial_in_reg <=0;
    direction_reg <=0;
    red_op_A_reg <=0;
    red_op_B_reg <=0;
    bypass_A_reg <=0;
    bypass_B_reg <=0;
    out_reg <= 0 ;  
  end
  else begin
    A_reg <= A;
    B_reg <= B;
    op_reg <= opcode;
    cin_reg <= cin; 
    serial_in_reg <= serial_in;
    direction_reg <= direction;
    red_op_A_reg <= red_op_A;
    red_op_B_reg <= red_op_B;
    bypass_A_reg <= bypass_A;
    bypass_B_reg <= bypass_B;
    out_reg <= y;  

  if ((opcode == 6) | (opcode ==7)|((red_op_A | red_op_B)==1) && ( (op_reg !=0) & (op_reg !=1) )) begin
         leds_reg <= ~leds_reg;
      if( bypass_A )
         out_reg <= A_reg;
      else if(bypass_B)
         out_reg <= B_reg;
      else
         out_reg <= 6'b000000;
    end
  end
end

always @(*) begin
  
  // testing the priorities
  if(INPUT_PRIORITY == "A") begin
    if((red_op_A_reg ==1) && (red_op_B_reg ==1))
     flag_red_A = 1;

    if( (bypass_A_reg == 1) && (bypass_B_reg ==1))
     flag_bypass_A = 1;
  end 
  
  else if (INPUT_PRIORITY == "B") begin
    if((red_op_A_reg ==1) && (red_op_B_reg ==1))
      flag_red_B = 1;

    if( (bypass_A_reg == 1) && (bypass_B_reg ==1))
      flag_bypass_B = 1;
  end    
  //  
  

    
    
  if (flag_bypass_A ==1)  // both are working but the priority is for A
    y = A_reg;
  else if(flag_bypass_B ==1)  //both are working but the priority is for B
    y = B_reg;
  else if(bypass_A_reg == 1)
    y = A_reg;
   else if( bypass_B_reg == 1 )
    y = B_reg;
    
  else begin

  case (op_reg) 
    0: begin 
        if(flag_red_A)  // both are working but the priority is for A
          y = &A;
        else if(flag_red_B)  //both are working but the priority is for B
          y = &B;
        else if(red_op_A_reg)  //only A is working
          y = &A;
        else if(red_op_B_reg)  //only B is working
          y = &B;
        else if ( (red_op_A_reg ==0) && (red_op_B_reg ==0))
          y = A_reg & B_reg; 
       end
       
    1: begin 
        if(flag_red_A)  // both are working but the priority is for A
           y = ^A;
        else if(flag_red_B)  //both are working but the priority is for B
           y = ^B;
        else if(red_op_A_reg) //only A is working
           y = ^A;
        else if(red_op_B_reg)  //only B is working
           y = ^B;
        else if ( (red_op_A_reg ==0) && (red_op_B_reg ==0))
           y = A_reg ^ B_reg;
       end
       
    2: begin
        if(FULL_ADDER == "ON")
          y = A_reg + B_reg + cin_reg;
        else if (FULL_ADDER == "OFF")
          y = A_reg + B_reg;
       end
       
    3: y = A_reg * B_reg;
    
    4: begin  //shifting
       if (direction_reg)
         y = {y[4:0] , serial_in_reg};
       else
         y = {serial_in_reg , y[5:1]};
       end
       
    5: begin
        if (direction_reg)
          y = {y[4:0] , y[5]} ;
        else
          y = {y[0] , y[5:1]} ;
        end 
  endcase
  end
end
endmodule
