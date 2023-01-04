function [A_picup_addr, B_picup_addr, X_dest_addr, Y_dest_addr, Next_addr] = address_gen(Layer, Prev_addr, CONVERSION_FORMAT)

bit_len = log2(CONVERSION_FORMAT);

one = CONVERSION_FORMAT-1;
f_one = fi(one, 0, bit_len, 0);

f_layer = fi(2^(Layer-1), 0, bit_len, 0);
f_not_layer = bitxor(f_layer, f_one);

f_prev_addr = fi(Prev_addr, 0, bit_len, 0);

f_a = f_prev_addr;
f_b = bitor(f_prev_addr, f_layer);

f_b_p = fi(f_b+1, 0, bit_len, 0);
f_next = bitand(f_b_p, f_not_layer);

tmp = [f_a; f_b];
if Layer == 1
    for i = 1:(bit_len-1)
        sh = bitsliceget(tmp, bit_len, i);
        sh = bitrol(sh, 1);
        if i == 1 
            tmp = sh;
        else
            conc = bitsliceget(tmp, i-1, 1);
            tmp = bitconcat(sh, conc);
        end
    end
    
    f_a_p = tmp(1);
    f_b_p = tmp(2);
    
else 
    f_a_p = f_a;
    f_b_p = f_b;
end 
% pick-up adresses
A_picup_addr = int32(f_a_p) + 1;
B_picup_addr = int32(f_b_p) + 1;

%Destination addresses
X_dest_addr = int32(f_a) + 1;
Y_dest_addr = int32(f_b) + 1;
%Next start address
Next_addr = int32(f_next);