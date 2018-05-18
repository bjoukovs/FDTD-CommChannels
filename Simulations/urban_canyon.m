clear all;
close all;

addpath('..');
c=3e8;

x0 = 0;
y0 = 0;
xf = 2.5*1;
yf = 2.5*1;

x_step = c/(1e9)/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 1*1000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));

% eps_rel(40,1:100) = ones(1,100)*1; %ATTENTION PAS 10^6 car c'est eps RELATIF
% eps_rel(60,1:100) = ones(1,100)*1; 
% mu_rel(40,1:100) = ones(1,100)*5000; %ici c'est bien la bonne valeur de mu relative
% mu_rel(60,1:100) = ones(1,100)*5000;

eloignement=5;

eps_rel(1:length(y),floor(length(x)/2)-eloignement) = ones(length(y),1)*1; %ATTENTION PAS 10^6 car c'est eps RELATIF
eps_rel(1:length(y),floor(length(x)/2)+eloignement) = ones(length(y),1)*1; 
mu_rel(1:length(y),floor(length(x)/2)-eloignement) = ones(length(y),1)*5000; %ici c'est bien la bonne valeur de mu relative
mu_rel(1:length(y),floor(length(x)/2)+eloignement) = ones(length(y),1)*5000;

xs=floor(length(x)/2);
ys=floor(length(y)/2);
sources = {};
sources{1} = [xs, ys, 1, 0];

simParams.tverif=1:50:length(t)+1; %attention indexes, not real times

outputs = computeFDTD(x,y,t,eps_rel,mu_rel,'sources',sources,'movie','none','graphics', @myGraphics,'special','urbancanyon','others',simParams);

verifE=outputs.verifE;
verifPoynting=outputs.verifPoynting;
% av=1/3*[1 1 1]; %moving average to smooth
% verifE(2:end)=conv(verifE(2:end),av,'same');
% verifPoynting(2:end)=conv(verifPoynting(2:end),av,'same');
posy_ls=outputs.posy_ls;
figure;stem(posy_ls,verifE);title('Decrease of E amplitude with distance')
xlabel('Distance (y) from the source [m]');
ylabel('Electric field amplitude [V/m]')
figure;stem(posy_ls,verifPoynting);title('Decrease of Power Density (S) with distance')
xlabel('Distance (y) from the source [m]');
ylabel('Norm of Poynting vector [W/m^2]')

function myGraphics(fig)
    figure(fig);
    eloignement=5;
    line([floor(251/2)-eloignement floor(251/2)-eloignement],[1 251]); %251=length(x) et 251=length(y)
    line([floor(251/2)+eloignement floor(251/2)+eloignement],[1 251]);
%     line([0 100],[40 40])
%     line([0 100],[60 60])
end

%FDTD_compute(x,y,t,25,50,eps_rel,mu_rel,1,'line([0 100],[40 40]);line([0 100],[60 60])')