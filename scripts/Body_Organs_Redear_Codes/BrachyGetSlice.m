function [x,y,z] = BrachyGetSlice(i,j)
%=========================================================================%
%  
% Description:
%   Function that reads from data contours of region of interest i in slice j  
%
% Inputs:
%   i              - id of the region of interest 
%   j              - id of the slice to consider
%
% Outputs:
%   x              - vector containing x-coordinates of contour  
%   y              - vector containing y-coordinates of contour
%   z              - vector containing z-coordinates of contour
%
% Author:
%   JPR
%
%=========================================================================%

    % STEP 1: Open file

     B=dicominfo('data/RS_anon_roi_nose_1_case_body_structure.dcm');
   
    % STEP 2: Access information about roi i
    roi    = fieldnames(B.ROIContourSequence.Item_5);
    slices = fieldnames(B.ROIContourSequence.Item_5.ContourSequence);

    % STEP 3: Access information about slice j of roi i
    npoints = B.ROIContourSequence.Item_5.ContourSequence.(slices{j}).NumberOfContourPoints;
    points  = B.ROIContourSequence.Item_5.ContourSequence.(slices{j}).ContourData;

    % STEP 4: Record the coordinates of the contour
    x = points(1:3:3*npoints)';
    y = points(2:3:3*npoints)';
    z = points(3:3:3*npoints)';

end

