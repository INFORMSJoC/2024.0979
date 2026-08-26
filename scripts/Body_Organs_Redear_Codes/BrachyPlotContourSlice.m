function [] = BrachyPlotContourSlice(nslices,zloc,zval,roitoplot,colors,singlecolor,figid)
%=========================================================================%
%  
% Description:
%   Function that plots a 2D slice of voxels in the color of their roi
%
% Inputs:
%   nslices        - vector containing the number of slices of each roi
%   zloc           - matrix with ith row being z-coordinates of slices
%   zval           - z-coordinate of the slice to represent
%   roitoplot      - vector containing all roi to plot
%   colors         - matrix whose ith row is rgb color code for roi i
%   singlecolor    - variable empty if using traditional colors or having
%                    the name of the one color to use
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
           if (abs(zloc(i,j)-zval)<1e-2)
               [x,y,z]=BrachyGetSlice(i,j);               
               H1=plot([x,x(1)],[y,y(1)],'k');
               H2=plot([x,x(1)],[y,y(1)],'.');
               
               if (isempty(singlecolor))
                  set(H1,'color',colors(i,:));
                  set(H2,'color',colors(i,:));
               else
                  set(H1,'color',singlecolor);
                  set(H2,'color',singlecolor);
               end
           end
        end        
    end
           
end