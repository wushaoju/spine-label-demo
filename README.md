# spine-label-demo

## Download dataset:
https://biomedia.doc.ic.ac.uk/data/spine/#Download

## step 1: unzip the nii.gz file:
        dirUnzip = dir(fullfile([path,nameFolds{j}],'*.nii.gz'));
        dirOutput = dir(fullfile([path,nameFolds{j}],'*.nii'));
        % If nii is not exist, unzip the nii.gz to nii
        if(isempty(dirOutput))
            gunzip([dirUnzip.folder,filesep,dirUnzip.name]);
        end
        
## step 2: load the info and volume V:       
        info = nii_read_header([fileFolder,dirOutput.name]);
        V = nii_read_volume(info);
        info.PixelSpacing=info.PixelDimensions(1:2);
        info.SpacingBetweenSlices=info.PixelDimensions(3);
