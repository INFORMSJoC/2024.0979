function [] = BrachyPlotContourVolume(nslices,zloc,roitoplot,colors,singlecolor,filled,figid)
%=========================================================================%
%  
% Description:
%   Function that plots a 2D slice of voxels in the color of their roi
%
% Inputs:
%   nslices        - vector containing the number of slices of each roi
%   zloc           - matrix with ith row being z-coordinates of slices
%   roitoplot      - vector containing all roi to plot
%   colors         - matrix whose ith row is rgb color code for roi i
%   singlecolor    - variable empty if using traditional colors or having
%                    the name of the one color to use
%   filled         - y/n indicator that says whether curved must be filled 
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
            
    % STEP 2: Plot the contour on a 2-D picture
    ss=size(roitoplot,2);    
    for s=1:ss
        i = roitoplot(s);
        for j=1:nslices(i)
               [x,y,z]=BrachyGetSlice(i,j);               
               H1=plot3([x,x(1)],[y,y(1)],[z,z(1)],'k');
               if (filled=='y')
                  H2=fill3([x,x(1)],[y,y(1)],[z,z(1)],'k');
               end
               
               if (isempty(singlecolor))
                  set(H1,'Color',colors(i,:));
                  set(H2,'FaceColor',colors(i,:));                  
               else
                  set(H1,'Color',singlecolor);
                  set(H2,'FaceColor',singlecolor);                  
               end
        end
    end
      
end