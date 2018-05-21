clear all;
close all;

c=3e8;

x0 = 0;
y0 = 0;
xf = 500;
yf = 500;

f = 2.45e9;
lambda = c/f;
x_step = lambda/10; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 �a ne se propage plus

t0 = 0;
t_step = x_step/c/sqrt(2); %Stability (1D condition)
tf = t0 + 4001*t_step;

xf = 500*x_step;
yf = 500*x_step;


x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));



[E, Fading_matrix1, Fading_matrix3, Path_loss, Fading_matrix1_begin, Fading_matrix2, Fading_matrix4] = FDTD_compute_forfastfading(x,y,t,250,75,eps_rel,mu_rel,0,'');%box : 'line([50 100],[50 50]);line([50 50],[50 100]);line([50 100],[100 100]);line([100 100],[50 100]);')

%% Doppler shift

v = 1; %une case par seconde
temps = 0:v:29;
figure;
plot(temps,10*log10(Fading_matrix1(12,:)))
title('Average squared Electric Field amplitude in local area 1');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');
figure;
plot(temps,10*log10(Fading_matrix3(12,:)))
title('Average squared Electric Field amplitude in local area 3');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

figure;
plot(temps,10*log10(Fading_matrix1_begin(12,:)))
title('Average squared Electric Field amplitude in local area 1 before reflections');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

figure;
plot(temps,10*log10(Fading_matrix2(12,:)))
title('Average squared Electric Field amplitude in local area 2 before reflections');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

figure;
plot(temps,10*log10(Fading_matrix4(12,:)))
title('Average squared Electric Field amplitude in local area 4');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

%% Path loss
figure;
plot(0:v:249,10*log10(Path_loss(:,1)))
title('Average squared Electric Field amplitude on a vertical line');
xlabel('y step index [Delta y]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

%% With metallic plate in front of the source
mu_rel(85,200:300)=5000;
[E, Fading_matrix1, Fading_matrix3, Path_loss, Fading_matrix1_begin, Fading_matrix2, Fading_matrix4] = FDTD_compute_forfastfading(x,y,t,250,75,eps_rel,mu_rel,0,'');%box : 'line([50 100],[50 50]);line([50 50],[50 100]);line([50 100],[100 100]);line([100 100],[50 100]);')

%% Doppler shift

v = 1; %une case par seconde
temps = 0:v:29;
figure;
plot(temps,10*log10(Fading_matrix1(12,:)))
title('Average squared Electric Field amplitude in local area 1, with metallic plate');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');
figure;
plot(temps,10*log10(Fading_matrix3(12,:)))
title('Average squared Electric Field amplitude in local area 3, with metallic plate');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

figure;
plot(temps,10*log10(Fading_matrix1_begin(12,:)))
title('Average squared Electric Field amplitude in local area 1 before reflections, with metallic plate');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

figure;
plot(temps,10*log10(Fading_matrix2(12,:)))
title('Average squared Electric Field amplitude in local area 2 before reflections, with metallic plate');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

figure;
plot(temps,10*log10(Fading_matrix4(12,:)))
title('Average squared Electric Field amplitude in local area 4, with metallic plate');
xlabel('x step index [Delta x]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');

%% Path loss
figure;
plot(0:v:249,10*log10(Path_loss(:,1)))
title('Average squared Electric Field amplitude on a vertical line, with metallic plate');
xlabel('y step index [Delta y]');
ylabel('Average squared Electric Field amplitude [dB((V/m)^2)]');