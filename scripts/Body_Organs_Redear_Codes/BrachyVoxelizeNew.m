function [  inf33] = BrachyVoxelize()
%=========================================================================%
%  
% Description:
%   Function that reads from data contours of region of interest i in slice j  
%
% Inputs:
%   finename       - id of the region of interest 
%
% Outputs:
%   NA             - 
%
% Authors:
%   JPR
%   NMB
%
%=========================================================================%


    % STEP 1: Read basic information about the case
    
    [k,nroi,nslices,colors,bdsx,bdsy,bdsz,zspace,zloc,totalviolation] = BrachyBasicInfo('data/RS_anon_roi_nose_1_case_body_structure.dcm');
   
    % STEP 2: Compute voxels x-position and number of voxels in x-direction
    xmin   = min(bdsx(:,1));
    xmax   = max(bdsx(:,2));
    dx     = xmax - xmin
    zspace
    nroi
    nslices
    nvx    = ceil(dx/zspace)
    slackx = (nvx*zspace-(xmax-xmin))/2;
    xmin   = min(bdsx(:,1)) - slackx;
    
    % STEP 3: Compute voxels y-position and number of voxels in y-direction
    ymin   = min(bdsy(:,1));
    ymax   = max(bdsy(:,2));
    dy     = ymax - ymin;
    nvy    = ceil(dy/zspace)
    slacky = (nvy*zspace-(ymax-ymin))/2;   
    ymin   = min(bdsy(:,1)) - slacky;
    
    % STEP 4: Compute voxels z-position and number of voxels in z-direction
    zmin   = min(bdsz(:,1));
    zmax   = max(bdsz(:,2));
    dz     = zmax - zmin + 1e-6;
    nvz    = ceil(dz/zspace)
    
    % STEP 5: Compute total number of possible voxels          
    nvoxel = nvx*nvy*nvz;

    % STEP 6: Allocate a 3D matrix that will contain a positive number if
    %         the voxel belongs to a roi
    voxels = zeros(nvx,nvy,nvz);
    
    % STEP 7: Create prime numbers that will help match a voxel with the
    %         roi(s) it belongs to // voxel belongs to roi i if voxel is
    %         divisible by conv(i)
    pri=primes(1000);
    if (nroi==1)
        for s=1:1000
           % tracer=pri(s:s+nroi-1);
           
           % if (tracer(1)*tracer(2)>tracer(nroi)) break;end
          
           end
    %else
        tracer=pri(1:1+nroi-1);
    end
    clear pri;
    
    % STEP 8: Create new color for overlapping voxels
    %colors = [colors;sum(colors)/nroi];
    
    % STEP 9: Create new color for overlapping voxels    
    ind=1;
    for i=1:1
        % STEP 9.1: Find vector idx that order slices in increasing z value
        [trash,idx] = sort(zloc(i,1:nslices(i)));
        
        % STEP 9.2: Voxelize each slide of roi i one at a time
        for j=1:nslices(i)
            % STEP 9.2.1: Get the contour of roi i in slice j
            [x,y,z] = BrachyGetSlice(i,idx(j));
            
            % STEP 9.2.2: Convert contour into collection of voxels
            vox = BrachyVoxelizeSlice(xmin,ymin,zspace,nvx, nvy, x,y,i,colors,tracer);
          
                      
            % STEP 9.2.3: Store voxel slice information in 3D matrix
            %             If voxel belongs to two rois, multiply their
            %             tracers
            
            %% ==================== edited part for scaling voxels ====================
            %%                   ======= by NMB ========


            zid = ceil((z(1)+1e-6-zmin)/zspace);
            for ii=1:nvx
                for jj=1:nvy
                        if (vox(ii,jj)>0.5)
                            
                        if (voxels(ii,jj,zid)>0.5)
                            if(voxels(ii,jj,zid)~=vox(ii,jj) && rem(voxels(ii,jj,zid),vox(ii,jj))~=0)
                         
                            voxels(ii,jj,zid)=vox(ii,jj)*voxels(ii,jj,zid);
                            end
                        else
                           voxels(ii,jj,zid)=vox(ii,jj);
                          
                        end
                        end
                       
                     %   if (vox(ii,jj)>0.5)
                      %  if (voxels(ii,jj,zid)>0.5 && rem(voxels(ii,jj,zid),vox(ii,jj))~=0)
                       %     voxels(ii,jj,zid)=vox(ii,jj)*voxels(ii,jj,zid);
                      %  else
                           % voxels(ii,jj,zid)=vox(ii,jj);
                      %  end
                 %   end

                end
            end
            
            % STEP 9.2.4: If required, plot voxelized slice 
          
            
          % BrachyPlotVoxelizedSlice(xmin,ymin,zspace,nvx,nvy,voxels(:,:,zid),i,colors,tracer,1)
          % for a=0:k-1
           %BrachyPlotContourSlice(nslices,zloc,zmin+(zid-1)*zspace+a*ceil(zspace/k),i,colors,'b',0)
            % end
      %  end
    end
    end
    % STEP 10: Graphically represent 3D model as contours
   % BrachyPlotContourVolume(nslices,zloc,1:nroi,colors,[],'y',1);
   % view(-110,10);
   
    % STEP 11: Graphically represent 3D model as voxels
    
    
     %% ==================== edited part for scaling voxels ====================
     %%                  ======= Nasim Mirzavand Boroujeni========

    [inf33]=BrachyPlotVoxelizedVolume(xmin,ymin,zmin,zspace,nvx,nvy,nvz,voxels,1:nroi,colors,tracer,2);
   view(110,10);
%     
%    folder ='C:\Users\data';
%    pngFileName = sprintf('original3Dnew.fig');
%    fullFileName = fullfile(folder, pngFileName);
%    saveas(gca,fullFileName);


%    STEP 12: Graphically represent all slices  
        
%   for t=1:nvz
%    BrachyPlotVoxelizedSlice(xmin,ymin,zspace,nvx,nvy,voxels(:,:,t),1:nroi,colors,tracer,t+2);
%    
%      for a=0:k-1
%     BrachyPlotContourSlice(nslices,zloc,zmin+(t-1)*zspace+a*(zspace/k),1:nroi,colors,'b',0);
%     axis equal; axis tight;
%       hold on
%     end  
%       folder ='C:\Users\data\structures';
%    pngFileName = sprintf('org_%d.fig', t);
%     fullFileName = fullfile(folder, pngFileName);
%   saveas(gca,fullFileName);
%         
%         
%     
%    end
    
% STEP 13: Compute total voxels assigned to rois
totalvx=size(find(voxels>0),1)
  
nvx 
nvy 
nvz
zspace 

% filename ='C:\Users\data\structures\voxelized_structures.xlsx';
% sheet = 1;
% xlswrite(filename,inf33,sheet);
% xlswrite(filename,nvx,2,'A1');
% xlswrite(filename,nvy,2,'B1');
% xlswrite(filename,nvz,2,'C1');
%xlswrite(filename,totalvx,4,'D1');

end




