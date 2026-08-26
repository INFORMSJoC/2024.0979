function [] = BrachyPlotVoxelizedSlice(xmin,ymin,zspace,nvx,nvy,voxels,roitoplot,colors,tracer,figid)
%=========================================================================%
%  
% Description:
%   Function that plots a 2D slice of voxels in the color of their roi
%
% Inputs:
%   xmin           - minimum x value of voxels 
%   ymin           - minimum y value of voxels
%   zspace         - size of voxels
%   nvx            - number of voxels in x dimension
%   nvy            - number of voxels in y dimension
%   voxels         - (nvx,nvy)-matrix indicating whether voxel belongs to roi 
%   roitoplot      - vector containing roi to plot
%   colors         - matrix whose ith row is rgb color code for roi i
%   tracer         -
%   figid          - id of the figure where to do the plot; 0 if active figure.
%
% Outputs:
%   NA             -  
%
% Author:
%   JPR
%
%=========================================================================%

    % STEP 1: Create a new figure window if necessary
    if (figid>0) figure(figid);clf;hold on; end
    
    % STEP 2: Define vectors for describing 2D faces 
    squarex=[0,0,1,1,0];squarey=[0,1,1,0,0];
    
    % STEP 3: Represent all possible voxels in this slice   
    for i=1:nvx
        for j=1:nvy
            plot(xmin+zspace*(squarex+i-1),ymin+zspace*(squarey+j-1),'k');
        end
    end
    
    % STEP 4: Represent voxels of roi of interests in this slice
    rr            = size(tracer,2);
    qq            = prod(tracer);
    check         = -ones(1,qq);
    for ss = 1:size(roitoplot,2)
        check(tracer(roitoplot(ss))) = roitoplot(ss);
    end
        
    for i=1:nvx
        for j=1:nvy
            vx = voxels(i,j);
            if (vx>0.5)
                if (check(vx)==-1)
                    % figure out if this voxel must be plotted
                    check(vx)=0;
                    for r=1:size(roitoplot,2)                        
                        if (rem(vx,tracer(roitoplot(r)))==0)
                            check(vx)=rr+1;
                            break;
                        end
                    end
                end
                
                if (check(vx)>0.5)                
                    H=fill(xmin+zspace*(squarex+i-1),ymin+zspace*(squarey+j-1),'r');
                    set(H,'FaceColor',colors(check(vx),:));
                end
            end
        end
    end
    
    % STEP 5: Make axes equal (so voxels are cubes)
    axis equal

end

