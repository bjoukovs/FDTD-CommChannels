clear all;
close all;

addpath('..');

c=3e8;

x0 = 0;
y0 = 0;
xf = 2;
yf = 2;

x_step = c/1e9/50; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 2500*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));
sigma = zeros(length(y), length(x));

R=0.16; %radius of the head
xcenter=xf/2; %center of the head
ycenter=yf/2;
Ry = 0.10; %Y radius of head
Rx = 0.075; %X radius of head

%Note : Head is supposed to have a high reluctance, thus low magnetic
%conductivity. This makes the equations for H unchanged.

sigma_brain=1.3;
rho_brain=1.03;

xsource=round((xcenter-Rx)/x_step)-2;
ysource=round(ycenter/x_step)-1;

% Huawei P8 lite : max emission = 3.4W
% Using poynting at the source, E0 = sqrt(Z0 * Pr) = 35.8 V/m;

sources = {};
sources{1} = [xsource, ysource, 35.8, 0];

mask = zeros(size(eps_rel)+[1 1]);

for x_index=1:length(x)
    for y_index=1:length(y)
        if ((x(x_index)-xcenter)/Rx)^2 + ((y(y_index)-ycenter)/Ry)^2 <= 1
            eps_rel(y_index,x_index)=43; %for cerebral tissue
            mu_rel(y_index,x_index)=1;
            mask(y_index, x_index) = 1;
            sigma(y_index, x_index) = sigma_brain;
        end
    end
end


simParams = struct;
simParams.mask = mask;
simParams.startTime = 1500;
simParams.stopTime = 2500;

outputs = computeFDTD_dispersive(x,y,t,eps_rel,mu_rel,sigma,'graphics', @sar_graphics,...
'sources', sources, 'movie', 'save', 'special', 'measurepower', 'others', simParams);


power = outputs.power;


SAR_head=power*sigma_brain/rho_brain
subsarhead = SAR_head(115:225,115:225);

submask = mask(115:225, 115:225);

meanSAR = mean(nonzeros(subsarhead))
meanSAR2 = mean(nonzeros(subsarhead(:,1:round(length(subsarhead)/2-5))));

vol = 0.006^3 * nnz(subsarhead)
mass = vol * rho_brain

for xi = 1:length(submask)
   for yi = 1:length(submask)
      if submask(yi,xi) == 0
         subsarhead(yi,xi) = -100; 
      end
   end
end

colormap(hot);
imagesc(subsarhead, [-1 max(max(subsarhead))]);
colorbar;
title("local SAR (W/kg)");
xlabel(sprintf('Average SAR over head section: %f W/kg\n Average SAR over left half of brain : %f W/kg',meanSAR, meanSAR2));



%Since x_step = 0.006m, the "volume" of one element is 2.1600e-07 m³
%this volume corresponds to 2.22e-4 g

%SAR for a Huawei P8 Lite: SAR=0.39 W/kg


% power_dissipated=power_head;
% figure;plot(t,power_dissipated)
% title('Power dissipated in the brain, in function of time');
% xlabel('Time [s]');
% ylabel('Power [W]');
% figure;plot(t,SAR_head)
% title('SAR in function of time');
% xlabel('Time [s]');
% ylabel('SAR [W/kg]');

%Make the mean between two times values where the electric field is totally present in the head
%meanSAR=mean(SAR_head(1,601:1801))




function sar_graphics(fig)
  
    figure(fig);
    c=3e8;
    x_step = c/1e9/50; %Accuracy 1Ghz
    Ry = 0.10/x_step; %Y radius of head
    Rx = 0.075/x_step; %X radius of head
    xcenter = 1/x_step;
    ycenter = 1/x_step;
    
    theta = 0:0.1:2*pi;
    x = Rx * cos(theta) + xcenter;
    y = Ry * sin(theta) + ycenter;

    plot(x,y);
    %viscircles([xcenter/x_step ycenter/x_step],R/x_step,'LineWidth',0.2);
end
