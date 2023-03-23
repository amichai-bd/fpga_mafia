// TODO - later better to change it to a class that will give more random abilities.
parameter NUM_OF_FIFO_ACTIVE = 1;
parameter RANDOM_TEST = 0;
parameter ROUNDS = 4;
int num_fifo_active; 

if(RANDOM_TEST) begin
    num_fifo_active = $urandom_range(1,4); // 4 fifo for now.
end
else 
    num_fifo_active = NUM_OF_FIFO_ACTIVE;
$display("num_fifo_active id %0d",num_fifo_active);
if(RANDOM_TEST) begin
    num_fifo_active = $urandom_range(1,4); // 4 fifo for now.
end
else 
    num_fifo_active = NUM_OF_FIFO_ACTIVE;
    delay(10);
    push_fifo(0);
    delay(10);
    push_fifo(0);
    delay(10);
    for(int j = 0; j<ROUNDS; j++)   
      for (int i=0; i<num_fifo_active; i++) begin
       push_fifo(i);
       delay(100);
      end
    begin
        check_correct_output();
    end


