BCC = 6;
AWL = 10;
CLK_1 = 100E6;


CLK_1_per = 1/ CLK_1;

CLK_2_per = CLK_1_per * ceil(N/2^AWL) ;


CLK_2 = 1/CLK_2_per;

disp("CLK_1 = " + num2str(CLK_1, "%10.3e"));
disp("CLK_2 = " + num2str(CLK_2, "%10.3e"));



BCC = [2 3 4 5 6];
CLK_per = zeros(1, 5);
data = zeros(1, 5);

CLK_per(1:end) = 10E-9;
CLK_per = [5.5E-9 5E-9 6E-9 7E-9 7E-9];

for(i = 1:5)
    if (BCC(i) < 4)
        N = (2^(AWL-1) + 2)*AWL*BCC(i) + 4;
    else
        N = 2^(AWL-1)*AWL*BCC(i) + 4 + 4;
    end
    data(i) = CLK_per(i) * ceil(N/2^AWL);
    
end

figure('Name','FFT Timing analysis','NumberTitle','off');
subplot(2, 1, 1);
stem(BCC, data);
hold on;
plot(BCC, data);
%%ylim([0.5E-7 4E-7])
%%yticks([50E-9:50E-9:400E-9]);
%%yticklabels({'y = 50ns','y = 100ns','y = 150ns'})
xticks([2:1:6]);
xticklabels({'2','3', '4', '5', '6'})
xlabel("Butterfly clocks");
ylabel("s");
title("CLK period");
subplot(2, 1, 2);
stem(BCC, 1./data);
hold on;
plot(BCC, 1./data);
xticks([2:1:6]);
xticklabels({'2','3', '4', '5', '6'})
xlabel("Butterfly clocks");
ylabel("Hz");
title("CLK frequency");


