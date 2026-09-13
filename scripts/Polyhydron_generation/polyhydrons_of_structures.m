
filename = 'RAW_DATA/Selected_dwell_points.xlsx';

xCoordinates = xlsread(filename,1,'A:A');
yCoordinates = xlsread(filename,1,'B:B');
zCoordinates = xlsread(filename,1,'C:C');

convexHullFaces = convhull(xCoordinates,yCoordinates,zCoordinates,'Simplify',true);

trisurf(convexHullFaces,xCoordinates,yCoordinates,zCoordinates,'FaceColor','c')
axis equal
hold on
axis off

structureCentroid = [mean(xCoordinates), mean(yCoordinates), mean(zCoordinates)];

faceCount = size(convexHullFaces, 1);
faceNormalVectors = zeros(faceCount, 3);
facePlaneOffsets = zeros(faceCount, 1);
centroidSideByFace = zeros(faceCount, 1);

for faceIndex = 1:faceCount
    faceVertexIndices = convexHullFaces(faceIndex, :);
    [faceNormal, planeOffset] = calculatePlane( ...
        [xCoordinates(faceVertexIndices(1)), yCoordinates(faceVertexIndices(1)), zCoordinates(faceVertexIndices(1))], ...
        [xCoordinates(faceVertexIndices(2)), yCoordinates(faceVertexIndices(2)), zCoordinates(faceVertexIndices(2))], ...
        [xCoordinates(faceVertexIndices(3)), yCoordinates(faceVertexIndices(3)), zCoordinates(faceVertexIndices(3))]);

    hold on
    faceNormalVectors(faceIndex,:) = faceNormal;
    facePlaneOffsets(faceIndex,:) = planeOffset;

    centroidPlaneValue = dot(faceNormal, structureCentroid) + planeOffset;
    if centroidPlaneValue < 0
        centroidSideByFace(faceIndex,:) = -1;
    elseif centroidPlaneValue > 0
        centroidSideByFace(faceIndex,:) = 1;
    else
        centroidSideByFace(faceIndex,:) = 0;
    end
end

faceNormalVectors = double(faceNormalVectors);
facePlaneOffsets = double(facePlaneOffsets);
centroidSideByFace = double(centroidSideByFace);

function [normalVector, planeOffset] = calculatePlane(pointOne, pointTwo, pointThree)
syms normalX normalY normalZ offset

equations = [ ...
    normalX^2 + normalY^2 + normalZ^2 == 1, ...
    normalX * pointOne(1) + normalY * pointOne(2) + normalZ * pointOne(3) + offset == 0, ...
    normalX * pointTwo(1) + normalY * pointTwo(2) + normalZ * pointTwo(3) + offset == 0, ...
    normalX * pointThree(1) + normalY * pointThree(2) + normalZ * pointThree(3) + offset == 0];
solutions = solve(equations,[normalX,normalY,normalZ,offset]);

normalVector = [solutions.normalX(1,1), solutions.normalY(1,1), solutions.normalZ(1,1)];
planeOffset = solutions.offset(1,1);

end