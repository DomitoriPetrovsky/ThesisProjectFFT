%% top_FFT
% CONVERSION_FORMAT  =  2^n, n -  Natural number
% DATA_FORMAT:
%   "DOUBLE"          \/
%   "DOUBLE_SHIFT"    \/
%   "FIXT"            \/
%   "FIXT_SAT"        \/
%   "FIXT_SHIFT"      \/
%   "FIXT_EX"        \/
%
function [REAL_PART, IMAG_PART] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT)

LAYER_NUM = log2(CONVERSION_FORMAT);
BUT_NUM = CONVERSION_FORMAT/2;

ExWL = 25;
WL   = 16;
FL   = 15;

DATA_F = "";
SHIFT = 0;
T_D = 0;
T_W = 0;
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
            T_W = numerictype (1, WL, FL);
            T_D = T_W;
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
                T_W = numerictype (1, WL, FL);
                T_D = T_W;
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
                    T_W = numerictype (1, WL, FL);
                    T_D = T_W;
                    F = fimath( 'OverflowAction','Saturate', ...
                                'ProductMode', 'SpecifyPrecision', ...
                                'ProductWordLength', WL, ...
                                'ProductFractionLength', FL, ...
                                'SumMode','SpecifyPrecision', ...
                                'SumWordLength', WL, ...
                                'SumFractionLength',FL);
                else 
                    if DATA_FORMAT == "FIXT_EX"
                        DATA_F = "FIXT";
                        T_W = numerictype (1, WL, FL);
                        T_D = numerictype (1, ExWL, FL);
                        F = fimath( 'OverflowAction','Saturate', ...
                                    'ProductMode', 'SpecifyPrecision', ...
                                    'ProductWordLength', ExWL, ...
                                    'ProductFractionLength', FL, ...
                                    'SumMode','SpecifyPrecision', ...
                                    'SumWordLength', ExWL, ...
                                    'SumFractionLength',FL);
                    else
                        disp("TOP_FFT error! Check DATA_FORMAT param!!!");
                        return;
                    end
                end
            end
        end    
    end
end


% generate 
w_i = -sin_cos_table(1, CONVERSION_FORMAT, BUT_NUM, "SIN", DATA_F, F, T_W);
w_r =  sin_cos_table(1, CONVERSION_FORMAT, BUT_NUM, "COS", DATA_F, F, T_W);

DEBUG_LAYERS = zeros(CONVERSION_FORMAT , LAYER_NUM);

DEBUG_W_VAL = zeros(BUT_NUM , LAYER_NUM);

RAM_r = zeros(CONVERSION_FORMAT , 1);
RAM_i = zeros(CONVERSION_FORMAT , 1);


if DATA_F == "FIXT"
    RAM_r = fi(RAM_r, T_D, F);
    RAM_i = fi(RAM_i, T_D, F);
    
    DEBUG_LAYERS_i = fi(DEBUG_LAYERS, T_D, F);
    DEBUG_LAYERS_r = fi(DEBUG_LAYERS, T_D, F);
    
    DEBUG_W_VAL_i = fi(DEBUG_W_VAL, T_W, F);
    DEBUG_W_VAL_r = fi(DEBUG_W_VAL, T_W, F);
    
    
    REAL_COMP = fi(REAL_COMP, T_D, F);
    IMG_COMP = fi(IMG_COMP, T_D, F);
    
    bit_rev_address = 1;
    FILE_NAME = "cur_in_val.txt";
    input_file_gen(REAL_COMP, IMG_COMP, bit_rev_address, FILE_NAME);

    
    
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

        %if( (dest_addr_X == 8 || dest_addr_X == 9) && lay == 1)
        %   disp("point") 
        %end
        
        
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
        
        if DATA_F == "FIXT"
            DEBUG_W_VAL_r(but, lay) = W_r;
            DEBUG_W_VAL_i(but, lay) = W_i;
        else
            DEBUG_W_VAL(but, lay) = W_r + 1i*W_i;
        end
            
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

%if DATA_F == "FIXT"
%    REAL_PART = fi(RAM_r, T_W);
%    IMAG_PART = fi(RAM_i, T_W);
%else 
    REAL_PART = RAM_r;
    IMAG_PART = RAM_i;
%end

end