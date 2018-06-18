# spine-label-demo

## Download dataset:
https://biomedia.doc.ic.ac.uk/data/spine/#Download

## step 1: unzip the nii.gz file:
        dirUnzip = dir(fullfile([path,nameFolds{j}],'*.nii.gz'));
        dirOutput = dir(fullfile([path,nameFolds{j}],'*.nii'));
        // If nii is not exist, unzip the nii.gz to nii
        if(isempty(dirOutput))
            gunzip([dirUnzip.folder,filesep,dirUnzip.name]);
        end
