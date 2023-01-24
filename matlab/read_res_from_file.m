function res = read_res_from_file (FL,CONVERSION_FORMAT, FILE_NAME )
fileID = fopen(FILE_NAME','r');
l = fgetl(fileID);
l = fgetl(fileID);
l = fgetl(fileID);

sr = zeros(CONVERSION_FORMAT, 1);
si = zeros(CONVERSION_FORMAT, 1);

for i = 1:CONVERSION_FORMAT
    s = fgetl(fileID);
    sr(i) = str2num("0x" + s(1:end/2));
    si(i) = str2num("0x" + s(end/2+1:end));
end
fclose(fileID);
    sr = sr / 2^FL;
    si = si / 2^FL;
    sr(sr>1) = sr(sr>1)-2;
    si(si>1) = si(si>1)-2;
    
res = (sr + 1i * si);

