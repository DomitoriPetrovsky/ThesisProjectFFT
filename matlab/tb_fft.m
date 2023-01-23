%% tb_fft
close all;

CONVERSION_FORMAT = 32;
N = CONVERSION_FORMAT;
n = 0:N-1;
F = 4;
Fs = CONVERSION_FORMAT;

pd = makedist('Normal','mu',0.01,'sigma',0.05);
p = random(pd, size(n))';

REAL_COMP = sin(2*pi*(F/Fs)*n)';
%REAL_COMP = ones(CONVERSION_FORMAT, 1);
%IMG_COMP = zeros(CONVERSION_FORMAT, 1);
IMG_COMP = cos(2*pi*(F/Fs)*n)';
SIG = REAL_COMP + 1i*IMG_COMP;




% DATA_FORMAT
% "DOUBLE"          \/
% "DOUBLE_SHIFT"    \/
% "FIXT"            \/
% "FIXT_SAT"        \/
% "FIXT_SHIFT"      \/
% "FIXT_EX"         \/
DATA_FORMAT = "FIXT_SHIFT";

[REAL_PART, IMAG_PART] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT);

%DATA_FORMAT = "DOUBLE_SHIFT";

%[REAL_PART_D, IMAG_PART_D] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT);



my_fft = double(REAL_PART + 1i*IMAG_PART);
true_fft = fft(SIG, CONVERSION_FORMAT);
%true_fft = double(REAL_PART_D + 1i*IMAG_PART_D);

%% 
fileID = fopen('res_i.txt','r');
formatSpec = '%x';
hdl_i = fscanf(fileID, formatSpec);
fclose(fileID);
hdl_i = hdl_i / 2^15;
hdl_i(hdl_i>1) = hdl_i(hdl_i>1)-2;


fileID = fopen('res_r.txt','r');
formatSpec = '%x';
hdl_r = fscanf(fileID, formatSpec);
fclose(fileID);
hdl_r = hdl_r / 2^15;
hdl_r(hdl_r>1) = hdl_r(hdl_r>1)-2;

hdl_fft = hdl_r + 1i*hdl_i;


%% plot grafs
figure('Name','Plots Grafs','NumberTitle','off');
subplot(3, 2,1);
plot(0:N-1, real(my_fft));
title("real My FFT");
subplot(3, 2,3);
plot(0:N-1, real(true_fft));
title("real true FFT");
subplot(3, 2,2);
plot(0:N-1, imag(my_fft));
title("imag My FFT");
subplot(3, 2,4);
plot(0:N-1, imag(true_fft));
title("imag true FFT");
subplot(3, 2,5);
plot(0:N-1, real(true_fft) - real(my_fft));
title("real erore");
subplot(3, 2,6);
plot(0:N-1, imag(true_fft) - imag(my_fft));
title("imag erore");

%% stem grafs

figure('Name','Stem Grafs','NumberTitle','off');
subplot(3, 2,1);
stem(0:N-1, real(my_fft));
title("real My FFT");
subplot(3, 2,3);
stem(0:N-1, real(true_fft));
title("real true FFT");
subplot(3, 2,2);
stem(0:N-1, imag(my_fft));
title("imag My FFT");
subplot(3, 2,4);
stem(0:N-1, imag(true_fft));
title("imag true FFT");
subplot(3, 2,5);
stem(0:N-1, real(true_fft) - real(my_fft));
title("real erore");
subplot(3, 2,6);
stem(0:N-1, imag(true_fft) - imag(my_fft));
title("imag erore");

%% stem HDL

figure('Name','Stem HDL  and FIXT_MY','NumberTitle','off');
subplot(3, 2,1);
stem(0:N-1, real(my_fft));
title("real My FFT");
subplot(3, 2,3);
stem(0:N-1, real(hdl_fft));
title("real HDL FFT");
subplot(3, 2,2);
stem(0:N-1, imag(my_fft));
title("imag My FFT");
subplot(3, 2,4);
stem(0:N-1, imag(hdl_fft));
title("imag HDL FFT");
subplot(3, 2,5);
stem(0:N-1, real(hdl_fft) - real(my_fft));
title("real erore");
subplot(3, 2,6);
stem(0:N-1, imag(hdl_fft) - imag(my_fft));
title("imag erore");