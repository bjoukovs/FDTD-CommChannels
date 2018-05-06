%mur absV2

clear all;
close all;

c=3e8;
mu_0 = 4*pi*1e-7;


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


E = FDTD_compute_murabs(x,y,t,250,250,eps_rel,mu_rel,1,'')%,'line([50 90],[0 90]);')