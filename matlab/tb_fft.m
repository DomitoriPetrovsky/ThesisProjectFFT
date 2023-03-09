%% tb_fft
close all;

CONVERSION_FORMAT = 1024;
INVERS = 0;
N = CONVERSION_FORMAT;
n = 0:N-1;
F = 2;
Fs = CONVERSION_FORMAT;

pd = makedist('Normal','mu',0.01,'sigma',0.05);
p = random(pd, size(n))';

%REAL_COMP = 0.25*sin(2*pi*(93/Fs)*n)'+ 0.25*sin(2*pi*(300/Fs)*n)' + 0.25*sin(2*pi*(175/Fs)*n)'+ 0.25*sin(2*pi*(500/Fs)*n)';
%IMG_COMP = zeros(CONVERSION_FORMAT, 1);
%IMG_COMP = 0.2 + 0.6 * cos(2*pi*(222/Fs)*n + pi/4)' + 0.2 * sin(2*pi*(100/Fs)*n + pi/4)' ;
%SIG = REAL_COMP + 1i*IMG_COMP;

REAL_COMP = real(data)';
IMG_COMP =  imag(data)';

%REAL_COMP = real(test_fft);
%IMG_COMP = imag(test_fft);
SIG = REAL_COMP + 1i*IMG_COMP;

% DATA_FORMAT
% "DOUBLE"          \/
% "DOUBLE_SHIFT"    \/
% "FIXT"            \/
% "FIXT_SAT"        \/
% "FIXT_SHIFT"      \/
% "FIXT_EX"         \/
DATA_FORMAT = "FIXT_SHIFT";

[REAL_PART, IMAG_PART] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT, INVERS);

DATA_FORMAT = "DOUBLE_SHIFT";

%[REAL_PART_D, IMAG_PART_D] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT, INVERS);


my_fft = double(REAL_PART + 1i*IMAG_PART);
true_fft = fft(SIG, CONVERSION_FORMAT)./1024;
%true_fft = double(REAL_PART_D + 1i*IMAG_PART_D);
%% Extract Data 

f1 = fopen("cur_in_val.txt",'r');
f2 = fopen("data.txt",'w');
file = fscanf(f1, '%c');
fprintf(f2, file);
fclose(f1);
fclose(f2);
disp("The file has been copied!");

%% Load Data

FL = 15;
fileNAME = "res_r.txt";
hdl_fft_r = read_res_from_file(FL,CONVERSION_FORMAT, fileNAME);
fileNAME = "res_i.txt";
hdl_fft_i = read_res_from_file(FL,CONVERSION_FORMAT, fileNAME);

hdl_fft = (hdl_fft_r + 1i*hdl_fft_i);

disp("The file has been read!");

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
stem(0:N-1, abs(real(true_fft) - real(my_fft)));
title("real erore");
subplot(3, 2,6);
stem(0:N-1, abs(imag(true_fft) - imag(my_fft)));
title("imag erore");
%% amplitude and phase spectrum

figure('Name','Amplitude and phase spectrum(MY and TRUE)','NumberTitle','off');
subplot(3, 2,1);
stem(0:N-1, abs(my_fft));
title("amplitude My FFT");
subplot(3, 2,3);
stem(0:N-1, abs(true_fft));
title("amplitude TRUE FFT");
subplot(3, 2,2);
stem(0:N-1, angle(my_fft));
title("ANGLE My FFT");
subplot(3, 2,4);
stem(0:N-1, angle(true_fft));
title("ANGLE TRUE FFT");
subplot(3, 2,5);
stem(0:N-1, abs(true_fft) - abs(my_fft));
title("amplitude erore");
subplot(3, 2,6);
stem(0:N-1, (angle(true_fft)) - (angle(my_fft)));
title("ANGLE erore");


%% stem HDL

figure('Name','Stem HDL  and FIXT_MY','NumberTitle','off');
subplot(3, 2,1);
stem(0:N-1, real(true_fft));
title("real TRUE FFT");
subplot(3, 2,3);
stem(0:N-1, real(hdl_fft));
title("real HDL FFT");
subplot(3, 2,2);
stem(0:N-1, imag(true_fft));
title("imag TRUE FFT");
subplot(3, 2,4);
stem(0:N-1, imag(hdl_fft));
title("imag HDL FFT");
subplot(3, 2,5);
stem(0:N-1, abs(real(hdl_fft) - real(true_fft)));
title("real erore");
subplot(3, 2,6);
stem(0:N-1, abs(imag(hdl_fft) - imag(true_fft)));
title("imag erore");

%% amplitude and phase spectrum HDL

figure('Name','Amplitude and phase spectrum(MY and HDL)','NumberTitle','off');
subplot(3, 2,1);
stem(0:N-1, abs(true_fft));
title("amplitude TRUE FFT");
subplot(3, 2,3);
stem(0:N-1, abs(hdl_fft));
title("amplitude HDL FFT");
subplot(3, 2,2);
stem(0:N-1, angle(true_fft));
title("ANGLE TRUE FFT");
subplot(3, 2,4);
stem(0:N-1, angle(hdl_fft));
title("ANGLE HDL FFT");
subplot(3, 2,5);
stem(0:N-1, abs(abs(hdl_fft) - abs(true_fft)));
title("amplitude erore");
subplot(3, 2,6);
stem(0:N-1, abs((angle(hdl_fft)) -(angle(true_fft))));
title("ANGLE erore");
