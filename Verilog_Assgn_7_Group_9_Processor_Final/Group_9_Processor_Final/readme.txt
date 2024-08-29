The current inputs are set to a=-96,b=84.

FOR BOOTH:
1) iverilog -o out processor.v booth_im.v
2) vvp out > BOOTH.txt

FOR GCD:
1) iverilog -o out processor.v gcd_im.v
2) vvp out > GCD.txt

NOTE: OUTPUT is always available in R[2].			