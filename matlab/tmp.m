s = audioread("sample-3s.wav");

k =  4578;%5678;
N = 1024;

data =  s(k:k+N-1);
true_fft = fft(data, N);

figure('Name','Amplitude and phase spectrum(MY and TRUE)','NumberTitle','off');
subplot(3, 2,1);
%stem(0:N-1, abs(my_fft));
title("amplitude My FFT");
subplot(3, 2,3);
stem(0:N-1, abs(true_fft));
title("amplitude TRUE FFT");
subplot(3, 2,2);
%stem(0:N-1, sort(angle(my_fft)));
title("ANGLE My FFT");
subplot(3, 2,4);
stem(0:N-1, angle(true_fft));
title("ANGLE TRUE FFT");
subplot(3, 2,5);
%stem(0:N-1, abs(true_fft) - abs(my_fft));
title("amplitude erore");
subplot(3, 2,6);
%stem(0:N-1, sort(angle(true_fft)) - sort(angle(my_fft)));
title("ANGLE erore");
