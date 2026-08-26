% Read DICOM

B= dicominfo('RS_anon_roi_nose_1_case_body_structure.dcm');
% Load number of regions of interest
roi = fieldnames(B.ROIContourSequence);
nroi= size(roi,1);

% Loop over all regions of interest
% Create a matrix to store all coordinates
allXYZ = [];  % will end up as [N×3] array

for i=1:nroi % or whatever ROI indices you want
    color = (B.ROIContourSequence.(roi{i}).ROIDisplayColor)/255;
    slices = fieldnames(B.ROIContourSequence.(roi{i}).ContourSequence);
    nslices = numel(slices);

    for j = 1:nslices
        npoints = B.ROIContourSequence.(roi{i}).ContourSequence.(slices{j}).NumberOfContourPoints;
        points  = B.ROIContourSequence.(roi{i}).ContourSequence.(slices{j}).ContourData;

        x = points(1:3:3*npoints);
        y = points(2:3:3*npoints);
        z = points(3:3:3*npoints);

        % append to master matrix
        allXYZ = [allXYZ; [x(:) y(:) z(:)]];

        % plot (optional)
        H = plot3([x',x(1)],[y',y(1)],[z',z(1)]);
        set(H,'Color',color)
    end
end

axis off