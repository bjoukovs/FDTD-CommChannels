clear all;
close all;

c=3e8;

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

x_step = c/1e9/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 �a ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 10000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));


eps_rel(40,1:100) = ones(1,100)*1e6; %iron wall on x=50
eps_rel(60,1:100) = ones(1,100)*1e6; %iron wall on x=50
mu_rel(40,1:100) = ones(1,100)*5000;
mu_rel(60,1:100) = ones(1,100)*5000;

E = FDTD_compute(x,y,t,25,50,eps_rel,mu_rel,1,'')