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

%[E,power_free] = FDTD_compute_SAR(x,y,t,xsource,ysource,eps_rel,mu_rel,0,'',R,xcenter,ycenter);

for x_index=1:length(x)
    for y_index=1:length(y)
        dist=sqrt((x(x_index)-xcenter)^2+(y(y_index)-ycenter)^2);
        if dist<=R
            eps_rel(x_index,y_index)=43; %for cerebral tissue
            mu_rel(x_index,y_index)=1;
        end
    end
end

[E,E_square_head] = FDTD_compute_SAR(x,y,t,xsource,ysource,eps_rel,mu_rel,0,'',R,xcenter,ycenter);
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
