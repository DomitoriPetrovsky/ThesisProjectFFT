%% top_FFT
% CONVERSION_FORMAT  =  2^n, n -  Natural number
% DATA_FORMAT =  "DOUBLE", "FIXT"
%
%
function [REAL_PART, IMAG_PART] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT)

LAYER_NUM = log2(CONVERSION_FORMAT);
BUT_NUM = CONVERSION_FORMAT/2;

WL = 16;
FL = 15;

DATA_F = "";
SHIFT = 0;
T = 0;
F = 0;

if DATA_FORMAT == "DOUBLE"
    DATA_F = "DOUBLE";
else
    if DATA_FORMAT == "DOUBLE_SHIFT"
        DATA_F = "DOUBLE";
        SHIFT = 1;
    else
        if DATA_FORMAT == "FIXT"
            DATA_F = "FIXT";
            T = numerictype (1, WL, FL);
            F = fimath( 'OverflowAction','Wrap', ...
                        'ProductMode', 'SpecifyPrecision', ...
                        'ProductWordLength', WL, ...
                        'ProductFractionLength', FL, ...
                        'SumMode','SpecifyPrecision', ...
                        'SumWordLength', WL, ...
                        'SumFractionLength',FL);
        else 
            if DATA_FORMAT == "FIXT_SAT"
                DATA_F = "FIXT";
                T = numerictype (1, WL, FL);
                F = fimath( 'OverflowAction','Saturate', ...
                            'ProductMode', 'SpecifyPrecision', ...
                            'ProductWordLength', WL, ...
                            'ProductFractionLength', FL, ...
                            'SumMode','SpecifyPrecision', ...
                            'SumWordLength', WL, ...
                            'SumFractionLength',FL);
    
            else 
                if DATA_FORMAT == "FIXT_SHIFT"
                    DATA_F = "FIXT";
                    SHIFT = 1;
                    T = numerictype (1, WL, FL);
                    F = fimath( 'OverflowAction','Saturate', ...
                                'ProductMode', 'SpecifyPrecision', ...
                                'ProductWordLength', WL, ...
                                'ProductFractionLength', FL, ...
                                'SumMode','SpecifyPrecision', ...
                                'SumWordLength', WL, ...
                                'SumFractionLength',FL);
                else 
                    disp("TOP_FFT error! Check DATA_FORMAT param!!!");
                    return;
                end
            end
        end    
    end
end



w_i = -sin_cos_table(1, CONVERSION_FORMAT, BUT_NUM, "SIN", DATA_F, F, T);
w_r =  sin_cos_table(1, CONVERSION_FORMAT, BUT_NUM, "COS", DATA_F, F, T);

DEBUG_LAYERS = zeros(CONVERSION_FORMAT , LAYER_NUM);
RAM_r = zeros(CONVERSION_FORMAT , 1);
RAM_i = zeros(CONVERSION_FORMAT , 1);


if DATA_F == "FIXT"
    RAM_r = fi(RAM_r, T, F);
    RAM_i = fi(RAM_i, T, F);
    DEBUG_LAYERS_i = fi(DEBUG_LAYERS, T, F);
    DEBUG_LAYERS_r = fi(DEBUG_LAYERS, T, F);
    
    REAL_COMP = fi(REAL_COMP, T, F);
    IMG_COMP = fi(IMG_COMP, T, F);

end

lp = 1;

for lay = 1:LAYER_NUM
    add_w = 0;
    add_AB = 0;
    W_address = 1;
    
    bp = 10;
    
    for but = 1:BUT_NUM
        [lp, bp] = progress(LAYER_NUM, BUT_NUM, lay, but, lp, bp);
        
        [picup_addr_A, picup_addr_B, dest_addr_X, dest_addr_Y, add_AB] = address_gen(lay, add_AB, CONVERSION_FORMAT);

        
        if lay == 1 
            A_r = REAL_COMP(picup_addr_A); 
            A_i = IMG_COMP(picup_addr_A);
            B_r = REAL_COMP(picup_addr_B);
            B_i = IMG_COMP(picup_addr_B); 
        else 
            A_r = RAM_r(picup_addr_A); 
            A_i = RAM_i(picup_addr_A);
            B_r = RAM_r(picup_addr_B);
            B_i = RAM_i(picup_addr_B);
        end
            
        W_r = w_r(W_address);
        W_i = w_i(W_address);    
            
        [W_address, add_w] = w_address_gen(lay, CONVERSION_FORMAT, add_w);

        [X_r, X_i, Y_r, Y_i] = butterfly(A_r, A_i, B_r, B_i, W_r, W_i, SHIFT, DATA_F);
        
        RAM_r(dest_addr_X) = X_r;
        RAM_i(dest_addr_X) = X_i;
        
        RAM_r(dest_addr_Y) = Y_r;
        RAM_i(dest_addr_Y) = Y_i;
        
    end
    if DATA_F == "FIXT"
        DEBUG_LAYERS_r(:, lay) = RAM_r;
        DEBUG_LAYERS_i(:, lay) = RAM_i;
    else 
        DEBUG_LAYERS(:, lay) = RAM_r + 1i*RAM_i;
    end
end

REAL_PART = RAM_r;
IMAG_PART = RAM_i;
end