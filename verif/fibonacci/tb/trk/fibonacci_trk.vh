integer trk_fib;
initial begin 
    #1
    trk_fib = $fopen({"../../../target/fibonacci/tests/trk_fib.log"},"w");
    $fwrite(trk_fib,"---------------------------------\n");
    $fwrite(trk_fib,"Time  | Valid  | Result  |\n");
    $fwrite(trk_fib,"---------------------------------\n");  

end


always @(posedge clk) begin 
    $fwrite(trk_fib,"%1t    |  %1h      |%8h\n", $realtime, valid, result);
end