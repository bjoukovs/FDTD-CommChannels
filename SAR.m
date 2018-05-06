clear all;
close all;

c=3e8;

x0 = 0;
y0 = 0;
xf = 2*1;
yf = 2*1;

x_step = c/1e9/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 4*1000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

R=0.16; %radius of the head
xcenter=xf/2; %center of the head
ycenter=yf/2;

xsource=round((xcenter-R)/x_step)-1;
ysource=round(ycenter/x_step);

sources = {};
sources{1} = [xsource, ysource, 1, 0];

for x_index=1:length(x)
    for y_index=1:length(y)
        dist=sqrt((x(x_index)-xcenter)^2+(y(y_index)-ycenter)^2);
        if dist<=R
            eps_rel(x_index,y_index)=43; %for cerebral tissue
            mu_rel(x_index,y_index)=1;
        end
    end
end


simParams = struct;
simParams.R = R;
simParams.xcenter = xcenter;
simParams.ycenter = ycenter;
simParams.startTime = 500;

outputs = computeFDTD(x,y,t,eps_rel,mu_rel,'graphics', @sar_graphics,...
'sources', sources, 'movie', 'show', 'special', 'SAR', 'others', simParams);


Ez = outputs.Ez;
E_square_head = outputs.E_square_head;


sigma_brain=1.3;
rho_brain=1.03;
SAR_head=E_square_head*sigma_brain/rho_brain

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
    xcenter = 1;
    ycenter = 1;
    R = 0.16;
    c=3e8;
    x_step = c/1e9/30; %Accuracy 1Ghz

    
    viscircles([xcenter/x_step ycenter/x_step],R/x_step,'LineWidth',0.2);
end
