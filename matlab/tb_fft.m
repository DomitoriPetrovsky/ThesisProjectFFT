%% tb_fft
close all;

CONVERSION_FORMAT = 128;
N = CONVERSION_FORMAT;
n = 0:N-1;
F = 6;
Fs = CONVERSION_FORMAT;
REAL_COMP = 0.25*sin(2*pi*(F/Fs)*n)' + 0.25*sin(2*pi*(32/Fs)*n)' + 0.25*cos(2*pi*(12/Fs)*n)' + 0.25*sin(2*pi*(1/Fs)*n)';
%REAL_COMP = ones(CONVERSION_FORMAT, 1);
IMG_COMP = zeros(CONVERSION_FORMAT, 1);
SIG = REAL_COMP + 1i*IMG_COMP;


% DATA_FORMAT
% "DOUBLE"          \/
% "DOUBLE_SHIFT"    \/
% "FIXT"            \/
% "FIXT_SAT"        \/
% "FIXT_SHIFT"      \/
DATA_FORMAT = "FIXT_SHIFT";

[REAL_PART, IMAG_PART] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT);

DATA_FORMAT = "DOUBLE_SHIFT";

%[REAL_PART_D, IMAG_PART_D] = top_FFT(REAL_COMP, IMG_COMP, CONVERSION_FORMAT, DATA_FORMAT);


my_fft = REAL_PART + 1i*IMAG_PART;
true_fft = fft(SIG, CONVERSION_FORMAT);
%true_fft = REAL_PART_D + 1i*IMAG_PART_D;


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