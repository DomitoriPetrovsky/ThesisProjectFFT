function res = sin_cos_table(F, FS, N, TYPE, DATA_FORMAT, FIM, T)

if TYPE == "cos" || TYPE == "Cos" || TYPE == "COS"
    if DATA_FORMAT == "DOUBLE"
        n = 0:N-1;
        res = cos(2*pi*(F/FS)*n);
        return;
    end
    
    if DATA_FORMAT == "FIXT"
        n = 0:N-1;
        res = fi(cos(2*pi*(F/FS)*n), T, FIM);
        return;
    end
    disp("Table error! Check DATA_FORMAT param!!!");
end

if TYPE == "sin" || TYPE == "Sin" || TYPE == "SIN"
    if DATA_FORMAT == "DOUBLE"
        n = 0:N-1;
        res = sin(2*pi*(F/FS)*n);
        return;
    end
    
    if DATA_FORMAT == "FIXT"
        n = 0:N-1;
        res = fi(sin(2*pi*(F/FS)*n), T, FIM);
        return;
    end 
    disp("Table error! Check DATA_FORMAT param!!!");
end
    disp("Table error! Check TYPE param!!!");
end 