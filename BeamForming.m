clear all;
close all;
clc;
%% Beam forming

c=3e8;

x0 = 0;
y0 = 0;
xf = 1/2;
yf = 1/2;

f=2.45e9;
x_step = c/f/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 2000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));

%sources
yl = 50;
xl = 40;
nb_sources = 6;
sourca = zeros(nb_sources,2);
spacing=floor((c/f)/4/x_step);
for i = 1: nb_sources
    sourca(i,:) = [yl, xl + spacing*i];
end


[E, coupe_distance, coupe_temps]=FDTD_compute_beam_forming(x,y,t,sourca,eps_rel,mu_rel,0,'');

figure;plot(y,coupe_distance);
figure;plot(t,coupe_temps);

