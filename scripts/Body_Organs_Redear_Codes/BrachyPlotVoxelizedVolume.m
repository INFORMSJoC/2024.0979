function [inf33] = BrachyPlotVoxelizedVolume(xmin,ymin,zmin,zspace,nvx,nvy,nvz,voxels,roitoplot,colors,tracer,figid)
%=========================================================================%


% Description:
%   Function that plots a 3D voxels in the color of their roi
%
% Inputs:
%   xmin           - minimum x value of voxels 
%   ymin           - minimum y value of voxels
%   zmin           - minimum z value of voxels
%   zspace         - size of voxels
%   nvx            - number of voxels in x dimension
%   nvy            - number of voxels in y dimension
%   nvz            - number of voxels in z dimension
%   voxels         - (nvx,nvy)-matrix indicating whether voxel belongs to roi 
%   roitoplot      - vector containing roi to plot
%   colors         - matrix whose ith row is rgb color code for roi i
%   tracers        - 
%   figid          - id of the figure where to do the plot; 0 if active figure.
%
% Outputs:
%   NA             -  
%
% Authors:
%   JPR
%   NMB
%
%=========================================================================%

    % STEP 1: Create a new figure window if necessary
    if (figid>0) figure(figid);clf;hold on; end

    % STEP 2: Define vectors for describing 2D faces of 3D voxels
    box1  = [0,0,1,1,0];
    box2  = [0,1,1,0,0];
    box3a = [0,0,0,0,0];
    box3b = [1,1,1,1,1];
    
    % STEP 3: Represent voxels in 3D object
    rr            = size(tracer,2);
    qq            = prod(tracer);
    check         = -ones(1,qq);
    for ss = 1:size(roitoplot,2)
        check(tracer(roitoplot(ss))) = roitoplot(ss);
    end
    indexn=1;
    
            for k=1:nvz
                for j=1:nvy
    for i=1:nvx
        
                vx = voxels(i,j,k);
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
                    H=fill3(xmin+zspace*(box1+i-1),ymin+zspace*(box2+j-1),zmin+zspace*(box3a+k-1),'r');
                    set(H,'FaceColor',colors(check(vx),:));
                           
                    
                    H=fill3(xmin+zspace*(box1+i-1),ymin+zspace*(box2+j-1),zmin+zspace*(box3b+k-1),'r');
                    set(H,'FaceColor',colors(check(vx),:));
                     
%                    set(H,'FaceColor',[1,1,1]);
                   
                   
                   H=fill3(xmin+zspace*(box1+i-1),ymin+zspace*(box3a+j-1),zmin+zspace*(box2+k-1),'r');
                    set(H,'FaceColor',colors(check(vx),:));
                     
%                      set(H,'FaceColor',[1,1,1]);
                    
                  H=fill3(xmin+zspace*(box1+i-1),ymin+zspace*(box3b+j-1),zmin+zspace*(box2+k-1),'r');
                 set(H,'FaceColor',colors(check(vx),:));
               
%                   set(H,'FaceColor',[1,1,1]);
                 
                 
                H=fill3(xmin+zspace*(box3a+i-1),ymin+zspace*(box1+j-1),zmin+zspace*(box2+k-1),'r');
                    set(H,'FaceColor',colors(check(vx),:));
                  
%                    set(H,'FaceColor',[1,1,1]);
                    H=fill3(xmin+zspace*(box3b+i-1),ymin+zspace*(box1+j-1),zmin+zspace*(box2+k-1),'r');
                 set(H,'FaceColor',colors(check(vx),:));
                 
%                  set(H,'FaceColor',[1,1,1]);
                   
                   
                    % ==================== edited part for scaling voxels ====================
                    %                   ======= by NMB ========

                   mx=(xmin+zspace*(box3b+i-1)+xmin+zspace*(box3a+i-1))/2;
                   my=(ymin+zspace*(box3b+j-1)+ymin+zspace*(box3a+j-1))/2;
                  mz=(zmin+zspace*(box3b+k-1)+zmin+zspace*(box3a+k-1))/2;
                  
                   n1=xmin+zspace*(box1+i-1);
                   n2=ymin+zspace*(box1+j-1);
                  n3=zmin+zspace*(box3a+k-1);
                   
                   o1=n1+zspace;
                   o2=ymin+zspace*(box1+j-1);
                   o3=zmin+zspace*(box3a+k-1);
                   
                    l1=n1+zspace;
                   l2=n2+zspace;
                   l3=zmin+zspace*(box3a+k-1);
                   
                    g1=xmin+zspace*(box1+i-1);
                   g2=n2+zspace;
                   g3=zmin+zspace*(box3a+k-1);
                   
                   
                    n11=xmin+zspace*(box1+i-1);
                   n21=ymin+zspace*(box1+j-1);
                  n31=zmin+zspace*(box3b+k-1);
                   
                   o11=n11+zspace;
                   o21=ymin+zspace*(box1+j-1);
                   o31=zmin+zspace*(box3b+k-1);
                   
                    l11=n11+zspace;
                   l21=n21+zspace;
                   l31=zmin+zspace*(box3b+k-1);
                   
                    g11=xmin+zspace*(box1+i-1);
                   g21=n21+zspace;
                   g31=zmin+zspace*(box3b+k-1);
                  
             
                 
                   
                % inf33(indexn,:)=[mx,my,mz,i+(j-1)*nvy,i+(j-1)*nvy+(k-1)*nvy*nvz,k,vx];
                   
                 inf33(indexn,:)=[mx(1,1),my(1,1),mz(1,1),n1(1,1),n2(1,1),n3(1,1), o1(1,1),o2(1,1),o3(1,1),l1(1,1),l2(1,1),l3(1,1),g1(1,1),g2(1,1),g3(1,1),n11(1,1),n21(1,1),n31(1,1),o11(1,1),o21(1,1),o31(1,1),l11(1,1),l21(1,1),l31(1,1),g11(1,1),g21(1,1),g31(1,1),i+(j-1)*nvx,i+(j-1)*nvx+(k-1)*nvx*nvy,k,j,i];
                % inf33(indexn,:)=[mx(1,1),my(1,1),mz(1,1),n1(1,1),n2(1,1),n3(1,1),o1(1,1),o2(1,1),o3(1,1),l1(1,1),l2(1,1),l3(1,1),g1(1,1),g2(1,1),g3(1,1),i+(j-1)*nvy,i+(j-1)*nvy+(k-1)*nvy*nvz,k,vx];
                   
%                  
%              plot3(mx(1,1),my(1,1),mz(1,1),'g.');
%                    
%                plot3(n1(1,1),n2(1,1),n3(1,1),'r.');
%                    
%              plot3(o1(1,1),o2(1,1),o3(1,1),'r.');
%                    
%        plot3(l1(1,1),l2(1,1),l3(1,1),'r.');
%                    
%              plot3(g1(1,1),g2(1,1),g3(1,1),'r.');
%                   
%                    
%        plot3(n11(1,1),n21(1,1),n31(1,1),'b.');
%                    
%     plot3(o11(1,1),o21(1,1),o31(1,1),'b.');
%                    
%             plot3(l11(1,1),l21(1,1),l31(1,1),'b.');
%                    
%                 plot3(g11(1,1),g21(1,1),g31(1,1),'b.');
              indexn=indexn+1;
                   
                end
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
              
                
                
                
                
                
                
                
                
                
                
                
                
                
                
              
                
                
                
                
                
              
                
                       
               
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
            end
        end
    end

    % STEP 4: Make axes tight     
    axis tight
    
end

