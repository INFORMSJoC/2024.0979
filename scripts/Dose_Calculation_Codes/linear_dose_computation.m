
filename = 'RAW_DATA/nose_case_1_voxels.xlsx';
sheet = 1;

% to make sure all of the points are in positive axis ranges we added the
% following constant values 
voxelCoordinates = xlsread(filename,sheet,'A:C');
voxelCoordinates(:,1) = voxelCoordinates(:,1) + 81;
voxelCoordinates(:,2) = voxelCoordinates(:,2) + 93;


%changing the cell array to the matrix to be readable 


filename = 'RAW_DATA/start_point_directions_on_needles.csv';
sheet = 1;
startPoints = csvread(filename);
filename = 'RAW_DATA/end_point_directions_on_needles.csv';

sheet = 1;
endPoints = csvread(filename);


needleCount = size(startPoints, 1);
doseByVoxelAndNeedle = zeros(size(voxelCoordinates, 1), needleCount);

for needleIndex = 1:needleCount

s1 = startPoints(needleIndex, :);
   
     s2 = endPoints(needleIndex, :);

     sourceLengthCm = 0.35;
     x = voxelCoordinates(:,1) / 10;
     
     y = voxelCoordinates(:,2) / 10;
     
     z = voxelCoordinates(:,3) / 10;
     
     [dose] = Dose_Computation(s2, s1, sourceLengthCm, x, y, z);
     

 doseByVoxelAndNeedle(:, needleIndex) = dose;

end 
    

for voxelIndex = 1:size(doseByVoxelAndNeedle,1)
    
    
    
minimumDoseByVoxel(voxelIndex,:) = min(doseByVoxelAndNeedle(voxelIndex,:));
maximumDoseByVoxel(voxelIndex,:) = max(doseByVoxelAndNeedle(voxelIndex,:));


end


filename = 'RAW_DATA/dose_received_by_voxels_nose_case_1.csv'
xlswrite(filename,doseByVoxelAndNeedle);


function [dose] = Dose_Computation (s1,s2,Lcm,x,y,z)
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

mid    = 0.5*(s1+s2);

% Anisotropy factor expressed at r = 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
phi=[1.010,0.970,0.960,0.960,0.960,0.960,0.970,0.970,0.970,0.970,0.970];

% Anisotropy function (theta,r) expressed at theta=0,10,20,....,180
%                               and at r=0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

FF=[
0.673	0.645	0.666	0.685	0.709	0.730	0.742	0.756	0.777	0.788	0.802;
0.746	0.742	0.754	0.771	0.786	0.797	0.812	0.822	0.830	0.837	0.848;
0.853	0.844	0.851	0.859	0.866	0.872	0.880	0.887	0.894	0.899	0.905;
0.913	0.907	0.912	0.917	0.921	0.923	0.926	0.930	0.934	0.937	0.941;
0.952	0.945	0.945	0.948	0.951	0.954	0.958	0.958	0.961	0.963	0.962;
0.969	0.967	0.969	0.970	0.971	0.972	0.975	0.975	0.976	0.978	0.979;
0.984	0.983	0.984	0.987	0.988	0.987	0.989	0.987	0.990	0.991	0.991;
0.995	0.991	0.997	0.999	1.000	0.997	1.000	0.999	0.998	0.999	1.000;
1.000	0.996	1.000	0.999	0.999	0.997	0.998	0.999	1.002	1.001	1.001;
1	1	1	1	1	1	1	1	1	1	1;
1.000	0.996	0.996	0.997	0.995	0.996	0.999	0.997	0.997	0.999	0.999;
0.996	0.992	0.994	0.995	0.995	0.994	0.997	0.997	0.998	0.999	1.000;
0.988	0.982	0.985	0.988	0.989	0.989	0.992	0.990	0.991	0.992	0.993;
0.973	0.971	0.971	0.972	0.975	0.974	0.976	0.977	0.977	0.978	0.979;
0.953	0.947	0.947	0.948	0.951	0.951	0.955	0.956	0.958	0.960	0.962;
0.915	0.908	0.909	0.911	0.913	0.917	0.920	0.925	0.928	0.928	0.932;
0.848	0.841	0.847	0.858	0.866	0.872	0.876	0.882	0.887	0.890	0.897;
0.714	0.704	0.724	0.742	0.761	0.771	0.787	0.797	0.808	0.820	0.831;
0.625	0.601	0.621	0.654	0.686	0.702	0.721	0.731	0.749	0.759	0.768];


% Compute number of points at which to compute dose
m      = size(x,1);
n      = size(x,2);

% Initialize dose matrix
dose = zeros(m,n);

% Compute geometry function at r0, theta0
b0  = sqrt(Lcm^2/4+r0^2);
GL0 = 2*acos(r0/b0)/(Lcm*r0);

% Loop to compute dose for each point
for i=1:m
  for j=1:n
      % Record point to evaluate dose at in vector p
      p      = [x(i,j),y(i,j),z(i,j)];

      % Compute parameters needed for geometry function
      r1     = norm(p-s1,2);
      r      = norm(p-mid,2);
      r2     = norm(p-s2,2);
      if (r<1e-10) dose(i,j)=NaN;continue;end; % Do not compute dose in the source     
      if (r1<r2) rtemp=r1;r1=r2;r2=rtemp;end
      b      = (r1^2-r2^2-Lcm^2)/(2*Lcm);
      angle0 = abs(r2-b); % if r2 is equal to b, then point is along the source... angle=0
      if (angle0>1e-10)
        theta2 = acos(b/r2);
        theta  = acos((Lcm/2+b)/r);
        theta1 = acos((Lcm+b)/r1);
        beta   = theta2-theta1;
      else
        theta2 = 0;
        theta  = 0;
        theta1 = 0;
        beta   = 0;
      end
      theta=real(theta);
      thetadeg = 180/pi*theta;
%      r
      
      % Compute geometry function
      if (abs(theta)<1e-8)||(abs(theta-pi)<1e-8) 
        GL = 1/(r^2-Lcm^2/4);
      else
        GL = beta/(Lcm*r*sin(theta));
      end
      
      % Radial-dose function 
      gL = 0.98690+1.5460E-02*r-2.9180E-03*r^2+1.1530E-04*r^3-2.6260E-06*r^4+3.2460E-08*r^5;
      
      % Anisotropy factor
      if (r<0.5) phian = phi(1);
        elseif (r<1) phian = (1-r)/(0.5)*phi(1)+(r-0.5)/(0.5)*phi(2); 
        elseif (r>=10) phian = phi(11);
      else
          idr    = floor(r)+1;
          lambda = (idr-r);
          phian  = lambda*phi(idr) + (1-lambda)*phi(idr+1);
      end
      
      % Anistropy function
      idt = floor(thetadeg/10)+1;
      lambdat = idt - 1/10*thetadeg;            
      if (r<0.5)
        F   = lambdat*FF(idt,1)+(1-lambdat)*FF(idt+1,1);
      elseif (r<1)
        idr = 1;
        lambdar = (1-r)/(0.5);
        F   = lambdat*lambdar*FF(idt,idr)+(1-lambdat)*lambdar*FF(idt+1,idr)+lambdat*(1-lambdar)*FF(idt,idr+1)+ (1-lambdat)*(1-lambdar)*FF(idt+1,idr+1);        
      elseif(r>=10)
        F   = lambdat*FF(idt,11)+(1-lambdat)*FF(idt+1,11);      
      else
        idr    = floor(r)+1;
        lambdar = (idr-r);
        F   = lambdat*lambdar*FF(idt,idr)+(1-lambdat)*lambdar*FF(idt+1,idr)+lambdat*(1-lambdar)*FF(idt,idr+1)+ (1-lambdat)*(1-lambdar)*FF(idt+1,idr+1);                
      
    
      end
     
      % Compute dose
   dose(i,j)=SK*Lambda*GL/GL0*gL*F;
  end
end

end
