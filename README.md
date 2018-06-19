# Spine-label-demo
A demo for labeling the transverse processes and spinous processes of the spine.
![](https://github.com/wushaoju/spine-label-demo/blob/master/Image/vertebral-spinous-process.gif)
## Author: 
- Shaoju Wu
## Download dataset:
https://biomedia.doc.ic.ac.uk/data/spine/#Download 
## Prerequisites:
- Matlab 2017 or above
## Spine-anatomy-video link:
https://www.spine-health.com/video/lumbar-spine-anatomy-video

## Step 1: unzip the nii.gz file:
        dirUnzip = dir(fullfile([path,nameFolds{j}],'*.nii.gz'));
        dirOutput = dir(fullfile([path,nameFolds{j}],'*.nii'));
        % If nii is not exist, unzip the nii.gz to nii
        if(isempty(dirOutput))
            gunzip([dirUnzip.folder,filesep,dirUnzip.name]);
        end
        
## Step 2: load the info and volume V:       
        info = nii_read_header([fileFolder,dirOutput.name]);
        V = nii_read_volume(info);
        info.PixelSpacing=info.PixelDimensions(1:2);
        info.SpacingBetweenSlices=info.PixelDimensions(3);
        
## Step 3: segment and visualize the image:       
        dirThresh = dir(fullfile([path,nameFolds{j}],'thresh.mat'));
        if(~isempty(dirThresh))
            load([fileFolder,'thresh.mat']); %loading threshold
        end
        
        thresh = 200 ;%(vary from case to case...)
        save([fileFolder,'thresh.mat'],'thresh'); %Saving threshold
              
        figure,
        [h1,h2] =  visibleCube(V,info,thresh,[2 2 1]);   % use [2 2 1] or [1 1 1] for finer resolution
        
 ## Step 4: labeled the transverse processes, spinous processes(middle part) of the spine:
        if( exist('tp') && exist('sp')) %%%%%%%%%%%%%%%<= setting the Break point here for labeling
            save([fileFolder,'label.mat'],'tp','sp'); % save the labels of transverse processes as tp, spinous processes as sp 
        end
 ## How to use data cursor to label spine data:
 ![](https://github.com/wushaoju/spine-label-demo/blob/master/Image/how_to_label.gif)
 ## Examples:
 Spinous processes(red),transverse processes(blue)
 ![](https://github.com/wushaoju/spine-label-demo/blob/master/Image/example1.jpg)
 ![](https://github.com/wushaoju/spine-label-demo/blob/master/Image/example2.jpg)
