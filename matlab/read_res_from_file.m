function res = read_res_from_file (FL,CONVERSION_FORMAT, FILE_NAME )
fileID = fopen(FILE_NAME','r');
l = fgetl(fileID);
l = fgetl(fileID);
l = fgetl(fileID);

s = zeros(CONVERSION_FORMAT, 1);


for i = 1:CONVERSION_FORMAT
    tmp = fgetl(fileID);
    s(i) = str2num("0x" + tmp);
end
fclose(fileID);

s = s / 2^FL;
s(s>1) = s(s>1)-2;

res =  s;

