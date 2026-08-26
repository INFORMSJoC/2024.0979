

% Read DICOM
A = dicominfo('.dcm');

% -------------------------
% Remove PHI
% -------------------------
A.PatientName                    = 'ANONYMIZED';
A.PatientID                      = 'ANONYMIZED';
A.PatientBirthDate               = '';
A.PatientSex                     = '';
A.StudyDate                      = '';
A.StudyTime                      = '';
A.AccessionNumber                = '';
A.ReferringPhysicianName         = '';
A.PerformingPhysicianName        = '';
A.OperatorsName                  = '';
A.InstitutionName                = '';
A.InstitutionAddress             = '';
A.InstitutionalDepartmentName    = '';
A.StationName                    = '';
A.StudyDescription               = '';
A.SeriesDescription              = '';

% Save anonymized DICOM
outFile = '/Users/jamalzadehsaeed/Downloads/Nov 2025 desktop files/new cases/need0_anon.dcm';
dicomwrite([], outFile, A, 'CreateMode', 'copy');
fprintf('Anonymized DICOM saved to: %s\n', outFile);

% -------------------------
% Process needles
% -------------------------
rods = fieldnames(A.ApplicationSetupSequence);
nrods = size(rods, 1);

for i = 1:nrods
    needles = fieldnames(A.ApplicationSetupSequence.(rods{i}).ChannelSequence);
    nneedles = size(needles, 1);

    for j = 1:nneedles

        try

            dwellp = fieldnames(A.ApplicationSetupSequence.(rods{i}).ChannelSequence.(needles{j}).BrachyControlPointSequence);
            ndwellp = size(dwellp, 1);

            position = [];
            time = [];
            for k = 1:ndwellp
                position = [position, A.ApplicationSetupSequence.(rods{i}).ChannelSequence.(needles{j}).BrachyControlPointSequence.(dwellp{k}).ControlPoint3DPosition];
                time     = [time,     A.ApplicationSetupSequence.(rods{i}).ChannelSequence.(needles{j}).BrachyControlPointSequence.(dwellp{k}).CumulativeTimeWeight];
            end

            no   = time.';
            Apos = (position.') / 10;
            A1   = mean(Apos);
            L    = 0.35;
            A2   = Apos - A1;

            [V, d] = eig(A2.' * A2, 'vector');
            [~, idx] = max(d);
            u = -V(:, idx);

            r0 = mean(Apos);
            A3 = bsxfun(@minus, Apos, r0);
            Ccov = (A3' * A3) / (ndwellp - 1);
            [~, ~, u1p] = svd(Ccov, 0);

            u_norm = u.' / sqrt(sum(u.^2));

            W    = zeros(ndwellp, 3);
            Cpts = zeros(ndwellp, 3);

            ind = 1;
            for ii = 1:ndwellp
                W(ind, :)    = Apos(ii, :) + L/2 * u_norm;
                Cpts(ind, :) = Apos(ii, :) - L/2 * u_norm;
                ind = ind + 1;
            end

            D = [W, Cpts];
            D = D(1:2:end, :);

            scatter3(position(1,:), position(2,:), position(3,:), 20, 'filled', 'g')
            hold on

            xyz0 = mean(Apos, 2);
            xyz  = Apos - xyz0;
            [U, S, ~] = svd(xyz);
            dvec = U(:, 1);
            t    = dvec' * xyz;
            t1   = min(t);
            t2   = max(t);
            xzyl = xyz0 + [t1, t2] .* dvec;

            x  = xyz(1, :);
            y  = xyz(2, :);
            z  = xyz(3, :);
            xl = xzyl(1, :);
            yl = xzyl(2, :);
            zl = xzyl(3, :);

        catch ME
            fprintf('Skipping rod %d needle %d: %s\n', i, j, ME.message);
            continue
        end

    end % j loop
end % i loop
