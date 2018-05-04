clear all;
close all;
clc;
%% Beam forming

c=3e8;

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

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
y1 = 5;
x1 = 40;
nb_sources = 7;
sourca = zeros(nb_sources,2);

spacing=floor((c/f)/4/x_step);

% for i=1:nb_sources
    
%sourca=[y1,x1];

for i = 1: nb_sources
    sourca(i,:) = [y1, x1 + spacing*i];
end

R=0.5;
[E, coupe_distance, coupe_temps, coupe_circulaire]=FDTD_compute_beam_forming(x,y,t,sourca,eps_rel,mu_rel,0,'',R);

figure;plot(y,coupe_distance(1:end-1));title('Power with y coordinate at a fixed time');
xlabel('Vertical coordinate y [m]');ylabel('Received power [W]');
figure;plot(t,coupe_temps);
xlabel('Time [s]');ylabel('Received power [W]');
figure;plot(coupe_circulaire(:,2),coupe_circulaire(:,1)) %TO ANALYZE

