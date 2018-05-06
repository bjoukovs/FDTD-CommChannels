clear all;
close all;

c=3e8;

x0 = 0;
y0 = 0;
xf = 500;
yf = 500;
epaisseur = 40;

f = 2.45e9;
lambda = c/f;
x_step = lambda/10; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 �a ne se propage plus

t0 = 0;
t_step = x_step/c/sqrt(2); %Stability (1D condition)
tf = t0 + 2000*t_step;

xf = 500*x_step;
yf = 500*x_step;


x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));


sources = {}
sources{1} = [250,75,1,0];


outputs = computeFDTD(x,y,t,eps_rel,mu_rel,0,'graphics',@fastfading_graphics,...
    'sources', sources, 'special', 'fastfading', 'movie', 'none');

Ez = outputs.Ez;
Fading_matrix1 = outputs.Fading_matrix1;
Fading_matrix3 = outputs.Fading_matrix3;
Path_loss = outputs.Path_loss;

%% Doppler shift

v = 1; %une case par seconde
temps = 0:v:29;
figure(1)
plot(temps,10*log10(Fading_matrix1(12,:)))
figure(2)
plot(temps,10*log10(Fading_matrix3(12,:)))

%% Path loss
figure(3)
plot(0:v:249,10*log10(Path_loss(:,1)))



function fastfading_graphics(fig)
    figure(fig);
    
    line([50 100],[50 50]);
    line([50 50],[50 100]);
    line([50 100],[100 100]);
    line([100 100],[50 100]);
end
