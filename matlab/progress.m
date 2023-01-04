function [lay_n, but_n] = progress(LAYER_NUM, BUT_NUM, lay, but, lay_p, but_p)
if lay == lay_p
   disp("Current layer : " + num2str(lay) + " from " + num2str(LAYER_NUM));
   disp("Performed 0 %");
   lay_n = lay_p+1;
else
    lay_n = lay_p;
end

pr =  but/BUT_NUM * 100;

if (pr >= but_p)
    disp("Performed " + num2str(but_p) + " %");
    but_n = but_p + 10;
else
    but_n = but_p;
end

end