function [k,nroi,nslices,colors,bdsx,bdsy,bdsz,zspace,zloc,totalviolation] = BrachyBasicInfo(file)
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
%   x              -
%   y              -
%   roiid          -
%   roitoplot      - vector containing roi to plot
%   colors         - matrix whose ith row is rgb color code for roi i
%
% Outputs:
%   nroi           - number of regions of interest
%   nslices(i)     - number of slices in region of interest i
%   colors(i,:)    -  rgb triple representing color of roi i 
%   bdsx(i,k)      -  lowest/highest (k=1/k=2) x-values in roi i
%   bdsy(i,k)      -  lowest/highest (k=1/k=2) x-values in roi i
%   bdsz(i,k)      -  lowest/highest (k=1/k=2) x-values in roi i
%   zspace         - distance between zslices
%   totalviolation - amount of deviation in z-data from zspace z-spacing
%
% Author:
%   JPR
%
%=========================================================================%

%
% This function
%
%
% It returns:

%=============================================================================
%=============================================================================
%=============================================================================

    % STEP 1: 
    if (isempty(file))   

      file='data/RS_anon_roi_nose_1_case_body_structure.dcm';
   
       
    end
    % STEP 2: Open case file
    B = dicominfo(file);

    % STEP 3: Identify number of region of interests
    roi  = fieldnames(B.ROIContourSequence.Item_5);
    nroi = size(1,1);
    

    % STEP 4: Allocate output vectors and matrices
    nslices = zeros(nroi,1); 
    colors  = zeros(nroi,3);
    bdsx    = zeros(nroi,2);
    bdsy    = zeros(nroi,2);
    bdsz    = zeros(nroi,2);
    ztemp   = zeros(nroi,100);
    for i=1:nroi           
        bdsx(i,1)=inf;bdsx(i,2)=-inf;
        bdsy(i,1)=inf;bdsy(i,2)=-inf;
        bdsz(i,1)=inf;bdsz(i,2)=-inf;
    end    
    zspace=0;zevaluated='n';
    
    %% scaling factor newly added 
    k=1;
    %%
    % STEP 5: Identify number of slices in each region of interest
    for i=1:1
       
        % Step 5.1: Read the color of region of interest i
        colors(i,:)=(B.ROIContourSequence.Item_5.ROIDisplayColor)/255';
    
        % Step 5.2: Read the number of slices for region of interest i
        slices=fieldnames(B.ROIContourSequence.Item_5.ContourSequence);
        nslices(i)=size(slices,1);
    
        % Step 5.3: Keep z-coordinates of slices
        zz = zeros(1,nslices(i));
    
        % Step 5.4: Run over all the slices
        for j=1:nslices(i)
        
            % Step 5.4.1: Find the number of points and their coordinates in
            % the current slice
            npoints=B.ROIContourSequence.Item_5.ContourSequence.(slices{j}).NumberOfContourPoints;
            points=B.ROIContourSequence.Item_5.ContourSequence.(slices{j}).ContourData;

            % Step 5.4.2: Convert single vector into 3D vector
            x=points(1:3:3*npoints);       
            y=points(2:3:3*npoints);
            z=points(3:3:3*npoints);
    
            % Step 5.4.3: Find min/max coordinates for each roi            
            xmin = min(x); if (xmin<bdsx(i,1)) bdsx(i,1)=xmin; end
            xmax = max(x); if (xmax>bdsx(i,2)) bdsx(i,2)=xmax; end            
            ymin = min(y); if (ymin<bdsy(i,1)) bdsy(i,1)=ymin; end
            ymax = max(y); if (ymax>bdsy(i,2)) bdsy(i,2)=ymax; end            
            if (z(1)<bdsz(i,1)) bdsz(i,1)=z(1); end
            if (z(1)>bdsz(i,2)) bdsz(i,2)=z(1); end
            
            % Step 5.4.4: Record z-coordinates of slices
            zz(j) = z(1); 
        end        
   
         
        % Step 5.5: Compute distance between slices in scan
        
        %% edited for scaling voxels 
        ztemp(i,1:size(zz,2))=zz;
        
        zz = sort(zz);
        
        
        if (zevaluated=='n')
            if (nslices(i)>1)
%             zspace=(19.8-18.9)*5/3;
                zspace=(zz(2)-zz(1))*k;
               
            end
        end
        zspace
        % Step 5.6: Check that slices are spaced as thought
        zcheck=zspace*(0:nslices(i)-1)+zz(1);
        totalviolation=sum(abs(zz-zcheck));
    
    end
    
    % STEP 6: Eliminate useless columns of ztemp to get zloc
    
    tt = max(nslices);
    zloc = zeros(nroi,tt);
    zloc(:,:)=ztemp(:,1:tt);
     
end

