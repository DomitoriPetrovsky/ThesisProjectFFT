function res = input_file_gen(re, im, bit_rev_address, FILE_NAME)

disp("Create file " + FILE_NAME);
len = numel(re);
bit_len =  round(log2(len));

addr = 1:len;

if bit_rev_address == 1
    tmp = fi(addr, 0, bit_len);
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
    addrs = int32(tmp) + 1;
else 
    addrs = addr;
end
    
FILE_ID = fopen(FILE_NAME, 'w');

for i = 1:len
    s1 = re(addrs(i));
    s2 = im(addrs(i));
    fprintf(FILE_ID,'%s%s\n', s1.hex, s2.hex);
end
fclose(FILE_ID);

disp("FILE done!");
res = 1;
end
