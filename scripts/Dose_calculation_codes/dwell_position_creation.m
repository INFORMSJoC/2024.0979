

needleEndpoints = [

% start point of the needels
11.012651	1	199.9466395
1	26.84645312	95.16231063
1	32.8146509	95.04727079
1	15.39719148	95
1	4.943752154	95.43511471
1.665945749	1.00207016	95
		
% end point of the needels		
173	74.30399931	98.17549295
129.2879133	72.76500829	200
158.0155499	63.56422171	200
173	78.341282	193.5838013
146.2967316	85.27372108	200
173	78.07529681	189.9675526
];


allEndpoints = needleEndpoints;
needleIndex = 1;
dwellPointIndex = 1;
endpointDimensions = size(needleEndpoints);
needleCount = endpointDimensions(1,1)/2;
for currentNeedle = 1:needleCount
    
    
    needleLengthCm = sqrt(sum((allEndpoints(currentNeedle+needleCount,:)-allEndpoints(currentNeedle,:)).^2))/10;
    endpointDistanceCm = sqrt(sum((allEndpoints(currentNeedle+needleCount,:)/10-allEndpoints(currentNeedle,:)/10).^2));
    needleDirection = (allEndpoints(currentNeedle+needleCount,:)/10-allEndpoints(currentNeedle,:)/10)/endpointDistanceCm;
    
    distanceFromStartCm = 0.1;
    while(distanceFromStartCm<=needleLengthCm-0.1)
    dwellPointData(dwellPointIndex,:,:,:,:) = [allEndpoints(currentNeedle,:)/10+distanceFromStartCm*needleDirection,((allEndpoints(currentNeedle,:)/10+distanceFromStartCm*needleDirection)-needleDirection*0.35),((allEndpoints(currentNeedle,:)/10+distanceFromStartCm*needleDirection)+needleDirection*0.35),currentNeedle];
    
    distanceFromStartCm = distanceFromStartCm+0.1;
    dwellPointIndex=dwellPointIndex+1;
    end
    
    
    dwellPointEndIndexByNeedle(needleIndex,:) = dwellPointIndex-1;
    needleIndex=needleIndex+1;
end

middlePointX = dwellPointData(:,1) *10;
middlePointY = dwellPointData(:,2) *10;
middlePointZ = dwellPointData(:,3) *10;

scatter3(middlePointX,middlePointY,middlePointZ,200,'k','filled')
% 
% 
 filename = './start_point_directions_on_needles.csv';
csvwrite(filename,dwellPointData(:,4:6));
% 
filename = './end_point_directions_on_needles.csv';
csvwrite(filename,dwellPointData(:,7:9));
% 
 filename = './middle_point_directions_on_needles.csv';
csvwrite(filename,dwellPointData(:,1:3));
% 
% 
% 
filename = './needle_number.csv';
csvwrite(filename,dwellPointData(:,10));
