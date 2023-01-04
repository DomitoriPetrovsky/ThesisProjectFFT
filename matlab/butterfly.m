function [X_r, X_i, Y_r, Y_i] = butterfly(A_r, A_i, B_r, B_i, W_r, W_i, SHIFT, DATA_F)

if SHIFT == 1
    if DATA_F == "DOUBLE"
        A_r = A_r/2;
        A_i = A_i/2;
        B_r = B_r/2;
        B_i = B_i/2;
    else
        if DATA_F == "FIXT"
            A_r = bitshift(A_r, -1);
            A_i = bitshift(A_i, -1);
            B_r = bitshift(B_r, -1);
            B_i = bitshift(B_i, -1);
        end 
    end
end

BW_r = B_r * W_r - B_i * W_i;
BW_i = B_r * W_i + B_i * W_r;


X_r = A_r + BW_r;
X_i = A_i + BW_i;

Y_r = A_r - BW_r;
Y_i = A_i - BW_i;




end