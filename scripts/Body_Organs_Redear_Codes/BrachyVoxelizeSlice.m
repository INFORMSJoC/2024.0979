function [voxels] = BrachyVoxelizeSlice(xmin,ymin,zspace,nvx,nvy,x,y,roiid,colors,tracer)
%=========================================================================%
%  
% Description:
% Given a curve, and a discretization setting, find the voxelization for that slice
%
% Inputs:
%   xmin           - minimum x value of voxels 
%   ymin           - minimum y value of voxels
%   zspace         - size of voxels
%   nvx            - number of voxels in x dimension
%   nvy            - number of voxels in y dimension
%   x              -
%   y              -
%   roiid          - id of the roi to voxelize
%   roitoplot      - vector containing roi to plot
%   colors         - matrix whose ith row is rgb color code for roi i
%   tracer         - vector matching roi id to prime identifier
%
% Outputs:
%   voxels         - (nvx,nvy)-matrix indicating whether voxel belongs to roi 
%
% Author:
%   JPR
%
%=========================================================================%


    % STEP 1: Allocate memory for the slice information  
    voxels = zeros(nvx,nvy);

    % STEP 2: Record number of points on curve
    n = size(x,2);

    % STEP 3: Simplify the curve, moving points to nearest voxel center
    xx = zeros(1,n); yy = zeros(1,n);
    for k=1:n
        xx(k) = xmin+zspace*(ceil((x(k)-xmin)/zspace)-0.5);
        yy(k) = ymin+zspace*(ceil((y(k)-ymin)/zspace)-0.5);
    end

    % STEP 4: Delete consecutive duplicate points from curve description
    delete = zeros(1,n);
    for k=1:n-1
        if ((abs(xx(k)-xx(k+1))+abs(yy(k)-yy(k+1)))<1e-6) delete(k+1)=1;end
    end
    idx = find(delete==0);
    xxx = xx(idx);
    yyy = yy(idx);
    nnn = size(xxx,2);

    % STEP 5: For any three consecutive points, eliminate middle one if
    %         colinear to the other two
    
    delete = zeros(1,nnn);
    for k=3:nnn
        val = (yyy(k-1)- yyy(k-2))*(xxx(k)- xxx(k-1))- (xxx(k-1)- xxx(k-2))*(yyy(k)- yyy(k-1));
        if (abs(val)<1e-6)
            delete(k-1)=1;
        end
    end
    idx  = find(delete==0);
    xxxx = xxx(idx);
    yyyy = yyy(idx);
    nnnn = size(xxxx,2);
    
    
    % Wrap around the last point
    xxxx = [xxxx,xxxx(1)];
    yyyy = [yyyy,yyyy(1)];
    nnnn = nnnn+1;
    
        
    % STEP 6: The collection of points remaining define a polygon
    %         Determine if a voxel is in or out of the polygon, by shooting
    %         horizontal ray from the absolute left to the absolute
    %         right, computing wheter intersections occur. Voxel is inside
    %         if ray has encountered an odd number of intersections so far,
    %         voxel is outside if ray has encountered an even number of
    %         intersections so far...
    
    % Go through each collections voxel by y-axis
    for t=1:nvy
        for qqq=1:2
            yt=ymin+(t-0.5)*zspace+(-1)^qqq*zspace/10; %perturb
            yt1=ymin+(t-0.5)*zspace;
            xbreaks=[];
            xbreaksh=[];
            for k=1:nnnn-1
                if (yyyy(k)<=yyyy(k+1))
                    y1=yyyy(k); y2=yyyy(k+1);
                    x1=xxxx(k); x2=xxxx(k+1);
                else
                    y1=yyyy(k+1); y2=yyyy(k);
                    x1=xxxx(k+1); x2=xxxx(k);                
                end
                % xxx
                if ((y2-y1)>1e-6)
                    if (yt>=y1)&(yt<=y2)
                        lambda=(yt-y2)/(y1-y2);
                        %if (lambda>1e-6)
                            xt=lambda*x1+(1-lambda)*x2;
                            xbreaks=[xbreaks,xt];
                        %end
                    end
                else
                    if (abs(yt-y1)<1e-6)
                        xbreaksh=[xbreaksh,x1,x2];
                    end
                end
            end
            xbreaks=sort(xbreaks);
            xbreaksh=sort(xbreaksh);
                       
            for u=1:size(xbreaks,2)/2
                ii=ceil((xbreaks(2*u-1)-xmin)/zspace);
                jj=ceil((xbreaks(2*u)-xmin)/zspace);
                
                ii1=(xbreaks(2*u-1)-xmin)/zspace;
                jj1=(xbreaks(2*u)-xmin)/zspace;
                
                for ss=ii:jj
                    if (voxels(ss,t)==0) voxels(ss,t)=1;end
                end 
                %voxels(ii:jj,t)=1;
            end        
        end
    end

    % STEP 7: Scale the voxels binary status to match roi tracer    
    voxels=tracer(roiid)*voxels;

    % BrachyPlotVoxelizedSlice(xmin,ymin,zspace,nvx,nvy,voxels,roiid,colors,tracer,1)
    % plot(x,y,'g')
    % plot(xxxx,yyyy,'b*')      
    % plot(xxxx,yyyy,'b-')


end

