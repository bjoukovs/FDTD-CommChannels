function [Ez,coupe_distance,coupe_temps] = FDTD_compute_beam_forming(x,y,t,sourca,eps_rel,mu_rel,show_movie,custom_display)
    
    coupe_temps=zeros(1,length(t)); %power at a specific place (x0,y0) in function of time;
    coupe_distance=zeros(1,length(y)); %power at a specific instant t0 on all the y's

    colormapfile = matfile('hotcoldmap.mat');
    cm = colormapfile.cm;
    cm = cm/255;

    %Allocate space for movie
%     if show_movie==1
%         F(length(t)) = struct('cdata',[],'colormap',[]);
%         
%     end

    mu_0 = 4*pi*1e-7;
    eps_0 = 8.85e-12;
    c = 1/sqrt(mu_0*eps_0);

    lambda = c/1e9; %1 Ghz
    
    x_step = x(2)-x(1);
    y_step = y(2)-y(1);
    t_step = t(2)-t(1);
    Hx = zeros(length(y), length(x));
    Hy = zeros(length(y), length(x));
    Ez = zeros(length(y)+1, length(x)+1);
    alpha = (mu_rel).^-1 .*(t_step/mu_0/x_step);
    beta = (eps_rel).^-1 .*(t_step/eps_0/x_step);
    
    [n_sources,~]=size(sourca);
    p=1:n_sources;
    for i=1:length(t)

       %source
%        for p=1:n_sources
%            Ez(sourca(p,1),sourca(p,2))=sin(2*pi*1e9*t(i));
%        end
        
        Ez(sourca(p,1),sourca(p,2))=sin(2*pi*1e9*t(i));
           
        %Update of Hx, Hy
        for j=1:length(x)
            for k=1:length(y)
                

                %Hx

                Hx(k,j) = Hx(k,j) - alpha(k,j)*(Ez(k+1,j) - Ez(k,j));



                %Hy

                Hy(k,j) = Hy(k,j) + alpha(k,j)*(Ez(k,j+1) - Ez(k,j));

            end
        end

        %Update of Ez
        for l=2:length(x)
            for m=2:length(y)
               flag=0;
               for a=1:n_sources
                 if (l==sourca(a,2)) && (m==sourca(a,1))
                    flag=1; %to tell if the point is a source
                    break
                 end
               end
               if flag==1
                   l,m;
               else
                   Ez(m,l) = Ez(m,l) + beta(m-1,l-1)*(Hy(m,l) - Hy(m,l-1)) - beta(m-1,l-1)*(Hx(m,l)-Hx(m-1,l));
               end
               
%                  if ~(ismember(l,sourca(:,2))) || ~(ismember(m,sourca(:,1)))
%                     Ez(m,l) = Ez(m,l) + beta(m-1,l-1)*(Hy(m,l) - Hy(m,l-1)) - beta(m-1,l-1)*(Hx(m,l)-Hx(m-1,l));
%                  else
%                      l,m;
%                  end
                 
                 if m==60 && l==60
                     coupe_temps(i)=(Ez(m,l).^2)*0.5;
                 end
            end
        end
        
        if i==length(t)/4
            coupe_distance=(Ez(60,:).^2)*0.5;
        end
        
        if show_movie==1
            figure(2)
            %draw subplot for map
                colormap(cm);
                imagesc(Ez, [-1,1])
                xlabel('x');
                ylabel('y');
                %xticks(linspace(0,length(x)-1,10));
                %yticks(linspace(0,length(y)-1,10));
                %xticklabels( round(linspace(x(1),x(end),10),2) );
                %yticklabels( round(linspace(y(1),y(end),10),2) );
                %hold on;
                %imagesc(eps_rel_draw);
                eval(custom_display);
                %hold off;
                colorbar;
            
            %draw subplot for colorbar
                %subplot(1,2,2, 'position', [0.85 0.05 0.1 0.9]);
%                 figure(3)
%                 axis off
%                 cb = colorbar;
%                 cb.Limits = [-1 1]
               
            
            %Save movie
            
            %F(i) = getframe(gcf);
            
        end
        
    end
    
    %fig = figure;
    %movie(fig,F,2)
    
%     filename = 'FDTD_'+datestr(datetime('now'),'ddmmyy_HH_MM')+'.mp4'
%     video = VideoWriter(char(filename),'MPEG-4');
%     video.Quality = 90;
%     open(video);
%     for i=1:length(F)
%        frame = F(i);
%        writeVideo(video,frame);
%     end
%     close(video);
end