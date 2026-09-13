

filename = 'RAW_DATA/body_voxels.xlsx';
sheet = 1;

% to make sure all of the points are in positive axis ranges you may need to adjust the
% x-y-z coodinates 
voxelCoordinates = xlsread(filename,sheet,'A:C');
voxelCoordinates(:,1) = voxelCoordinates(:,1);
voxelCoordinates(:,2) = voxelCoordinates(:,2);

% 
filename = 'RAW_DATA/Selected_dwell_points.xlsx';

sheet = 1;

dwellPoints = xlsread(filename);

dwellPointCount = size(dwellPoints, 1);
doseByVoxelAndDwellPoint = zeros(size(voxelCoordinates, 1), dwellPointCount);

for dwellPointIndex = 1:dwellPointCount

sourcePosition = dwellPoints(dwellPointIndex,:);

     sourceLengthCm = 0.35;
     x = voxelCoordinates(:,1)/10;
     
     y = voxelCoordinates(:,2)/10;
     
     z = voxelCoordinates(:,3)/10;
     
     [dose] = Dose_Computation(sourcePosition/10, sourceLengthCm, x, y, z);
     
     
     
     
    
     
     



 doseByVoxelAndDwellPoint(:,dwellPointIndex) = dose;

end 
     




for voxelIndex = 1:size(doseByVoxelAndDwellPoint,1)
    
    
    
minimumDoseByVoxel(voxelIndex,:) = min(doseByVoxelAndDwellPoint(voxelIndex,:));
maximumDoseByVoxel(voxelIndex,:) = max(doseByVoxelAndDwellPoint(voxelIndex,:));


end


filename = './dose_received_by_voxels_point_source.csv';


csvwrite(filename,doseByVoxelAndDwellPoint);
 
 


function [dose] = Dose_Computation (mid,Lcm,x,y,z)
%
% Inputs:
% -------  
% s1:  3-D vector of the position of one end of the source
% s2:  3-D vector of the position of the other end of the source
% Lcm: length of the source (in cm)
% x:   m x n matrix of x-coordinates of points to evaluate dose at
% y:   m x n matrix of y-coordinates of points to evaluate dose at
% z:   m x n matrix of z-coordinates of points to evaluate dose at
%
% Outputs:
% --------
% dose: 


% Declare constants
r0     = 1;    %in cm
theta0 = pi/2; %in radians
SK     = 1;    % Air Kerma
Lambda = 1.13; % Dose-Rate Constant



% Anisotropy factor expressed at r = 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

% Compute number of points at which to compute dose
m      = size(x,1);
n      = size(x,2);

% Initialize dose matrix
dose = zeros(m,n);

% Compute geometry function at r0, theta0


% Loop to compute dose for each point
for i=1:m
  for j=1:n
      % Record point to evaluate dose at in vector p
      p      = [x(i,j),y(i,j),z(i,j)];

      % Compute parameters needed for geometry function
     
      r      = norm(p-mid,2);
     
      if (r<1e-10) dose(i,j)=NaN;continue;end; % Do not compute dose in the source     
     
      
     
      
      % Radial-dose function 
      gL = 0.98690+1.5460E-02*r-2.9180E-03*r^2+1.1530E-04*r^3-2.6260E-06*r^4+3.2460E-08*r^5;
      
      % Anisotropy factor
      
      
      % Anistropy function
     
    
     
      % Compute dose
   dose(i,j)=SK*Lambda*gL*r0^2/r^2;
  end
end




end
