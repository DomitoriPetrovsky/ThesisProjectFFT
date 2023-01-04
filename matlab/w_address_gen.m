function [W_address, g_out] = w_address_gen(Layer, CONVERSION_FORMAT, g_in)
bit_len = log2(CONVERSION_FORMAT);
inc = 2^(bit_len-Layer);
mask = 2^(bit_len-1)-1;
f_m = fi(mask, 0, bit_len, 0);

f_inc = fi(inc, 0, bit_len, 0);
f_g = fi(g_in, 0, bit_len, 0);

f_sum =  f_inc + f_g;
f_sum = bitsliceget(f_sum, bit_len, 1);
f_w = bitand(f_sum, f_m);

W_address = int32(f_w) + 1;
g_out =  int32(f_sum);