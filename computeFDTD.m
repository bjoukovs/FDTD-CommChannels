function outputs = computeFDTD(x,y,time,eps_rel,mu_rel,varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This function computes the Yee algorithm
    % - x is the vector of x positions
    % - y is the vector of y positions
    % - eps_rel is a matrix of the locals values of the relative
    % permittivity
    % - mu_rel is a matrix of the locals values of the relative
    % permeability
    
    %Options
    % 'movie' -> 'show' (default), 'save', 'none'
    % 'sources' -> cell containing the different sources {[x_source, y_source, amplitude, phase]}
    % 'graphics' -> function to execute to write graphical elements to the
    % plot. It must be a function with a figure input argument my_function(figure)
    % 'special' -> 'SAR', 'beamforming', 'fastfading'
    % 'others' -> structure that might contain other parameters for the
    % special simulation
    
    
    %Outputs
    %The outputs of computeFDTD is a structure that can vary based on the
    %selected simulation (Sar, Beamforming etc...)
    %However it always contains the final Ez field
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Input arguments management
    default_sources = {};
    default_graphics = @defaultGraphics;
    default_movie = 'show';
    default_others = struct;
    
    %Creating the input arguments parser
    p = inputParser;
    addOptional(p,'movie',default_movie);
    addOptional(p,'sources',default_sources);
    addOptional(p,'graphics',default_graphics);
    addOptional(p,'special','none');
    addOptional(p,'others',default_others);
    parse(p,varargin{:});
    
    %Retrieving the input arguments
    special = p.Results.special;
    show_movie = p.Results.movie;
    sources = p.Results.sources;
    spgraphics = p.Results.graphics;
    others = p.Results.others;
    
    SAR = 0;
    if strcmp(special, 'SAR')
       SAR = 1; 
    end
    
    
    %Setting up the color map
    colormapfile = matfile('hotcoldmap.mat');
    cm = colormapfile.cm;
    cm = cm/255;

    
    %Allocate space for movie
    if strcmp(show_movie,'save')
        F(length(time)) = struct('cdata',[],'colormap',[]); 
    end
    
    %output structure
    outputs = struct;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Setting up simulation parameters
    mu_0 = 4*pi*1e-7;
    eps_0 = 8.85e-12;
    c = 1/sqrt(mu_0*eps_0);
    f=1e9;
    lambda = c/f; %1 Ghz
    
    x_step = x(2)-x(1);
    y_step = y(2)-y(1);
    t_step = time(2)-time(1);
    Hx = zeros(length(y), length(x));
    Hy = zeros(length(y), length(x));
    Ez = zeros(length(y)+1, length(x)+1);
    alpha = (mu_rel).^-1 .*(t_step/mu_0/x_step);
    beta = (eps_rel).^-1 .*(t_step/eps_0/x_step);
    
    %Creating a mask for the sources positions
    sources_mask = ones(size(Ez));
    for src=1:length(sources)
       sources_mask(sources{src}(2), sources{src}(1)) = 0;
    end
    
    
    %Creating matrix for optionnal simulations
    
    %Fast fading
    Fading_matrix1 = zeros(30,30);
    Fading_matrix3 = zeros(30,30);
    Path_loss = zeros(250,1);
    
    %SAR
    E_square_head=0;
    
    %Beam forming
    coupe_temps=zeros(1,length(time)); %power at a specific place (x0,y0) in function of time;
    coupe_distance=zeros(1,length(y)); %power at a specific instant t0 on all the y's
    coupe_circulaire=[];
    matrix_power=zeros(length(y)+1,length(x)+1);
    
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% ACTUAL SIMULATION %%%%%%
     for t=1:length(time)
       t

       %%%% Updating the sources %%%%
       for src = 1:length(sources)
          Ez(sources{src}(2), sources{src}(1)) = sources{src}(3)*sin(2*pi*f*time(t) + sources{src}(4)); 
       end


        %%%%% Updating the H fields %%%%
        
        E_diff_Y = Ez(2:end,1:end-1)-Ez(1:end-1,1:end-1);
        E_diff_X = Ez(1:end-1,2:end)-Ez(1:end-1,1:end-1);
        Hx = Hx - alpha.*E_diff_Y;
        Hy = Hy + alpha.*E_diff_X;

       

        %%%%% Updating the E field %%%%%
        
        Hy_diff_x = Hy(2:end,2:end) - Hy(2:end,1:end-1);
        Hx_diff_y = Hx(2:end,2:end) - Hx(1:end-1,2:end);
        Ez(2:end-1,2:end-1) = Ez(2:end-1,2:end-1) + sources_mask(2:end-1,2:end-1).*(beta(1:end-1,1:end-1).*Hy_diff_x - beta(1:end-1,1:end-1).*Hx_diff_y);

        %%%% SAR ANALYSIS %%%%
       if SAR==1
           for l=1:length(x)
               for m=1:length(y)
                   if t>others.startTime
                        dist=sqrt((x(l)-others.xcenter)^2+(y(m)-others.ycenter)^2);
                        if dist<=others.R
                            E_square_head=E_square_head+(Ez(m,l)^2)*(x_step*y_step)/(length(time)-others.startTime); %
                            %ponderation factors: x_step*y_step=area of the pixel
                            %                     length(t): to average over time 
                        end
                   end
               end
           end
       end
        
        
        
        %%%% Updating movie and display %%%%
       if strcmp(show_movie,'show') || strcmp(show_movie,'save')
            fig = figure(1);
            colormap(cm);
            imagesc(Ez, [-1,1])
            xlabel({'x (m)';strcat('time: ', sprintf('%0.5e',time(t)), ' s')});
            ylabel('y (m)');
            xticks(linspace(0,length(x)-1,10));
            yticks(linspace(0,length(y)-1,10));
            xticklabels( round(linspace(x(1),x(end),10),2) );
            yticklabels( round(linspace(y(1),y(end),10),2) );
            hold on;
            %custom graphics
            feval(spgraphics,fig);
            hold off;
            colorbar;
            drawnow;
            
            %Saving movie frame
            if strcmp(show_movie,'save')
               F(t) = getframe(gcf); 
            end
            
       end
        
       
       %%%% FAST FADING ANALYSIS %%%%
       if strcmp(special,'fastfading')
          %zone1
            if t>1500 && t<=2000
                Fading_matrix1(:,:) = Fading_matrix1(:,:)+((Ez(250 + 25 : 250 + 25 + 30 -1,250 - 15 : 250 + 15 -1)).^2) * (0.5/500);
                Fading_matrix3(:,:) = Fading_matrix3(:,:)+((Ez(400 + 25 : 400 + 25 + 30 -1,50 - 15 : 50 + 15 -1)).^2) * (0.5/500);
                Path_loss(:,:) = Path_loss(:,:)+((Ez(251 : 500, 251)).^2) * (0.5/500);
            end 
       end
       
       
       
       %%%% BEAM FORMING ANALYSIS %%%%
       if strcmp(special,'beamforming')
           if t>others.startTime
                matrix_power=matrix_power+(Ez.^2); %average power at each point
           end
       end
       
        
    end
    
    
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%% Saving the movie %%%%
    if strcmp(show_movie,'save')
        filename = "FDTD_"+datestr(datetime('now'),'ddmmyy_HH_MM')+".mp4"
        video = VideoWriter(char(filename),'MPEG-4');
        video.Quality = 90;
        open(video);
        for i=1:length(F)
           frame = F(i);
           writeVideo(video,frame);
        end
        close(video);
    end
    
    
    %%% BEAM FORMING %%%
    if strcmp(special,'beamforming')
        R = others.R;
        matrix_power = matrix_power/(length(time)-others.startTime);
        
        eps=x_step/2;
        
        for l=1:length(x)
            for m=1:length(y)
                dist=sqrt((l-others.centerX)^2+(m-others.centerY)^2); %odd number of sources
                dist=dist*x_step; 
                if dist<R+eps && dist>R-eps
                     coupe_circulaire=[coupe_circulaire;matrix_power(m,l) atan2(m-others.centerX, l-others.centerY)];
                 end
            end
        end
    end
    
    
        
    %Output structure
    outputs.Ez = Ez;
    if strcmp(special, 'beamforming')
        outputs.matrix_power = matrix_power;
        outputs.coupe_temps = coupe_temps;
        outputs.coupe_circulaire = coupe_circulaire;
    end
    if strcmp(special, 'fastfading')
        outputs.Fading_matrix1 =  Fading_matrix1;
        outputs.Fading_matrix3 = Fading_matrix3;
        outputs.Path_loss = Path_loss;
    end
    if strcmp(special, 'SAR')
        outputs.E_square_head = E_square_head;
    end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    


function defaultGraphics(fig)

end