%% labeled the transverse processes, spinous processes of the spine
% Author: Shaoju Wu Date: 2018 06 07
% update 2018 06 25 
% Dataset: https://biomedia.doc.ic.ac.uk/data/spine/#Download
%% Identify the number of patiences for labeling
mainFolder = ['spine-1/'];% path of the dataset
dirFolder = dir(mainFolder);
isub = [dirFolder(:).isdir]; %# returns logical vector
nameMainFolds = {dirFolder(isub).name}';
nameMainFolds(ismember(nameMainFolds,{'.','..'})) = []; % Obtain the name of the folder 
num = length(nameMainFolds);
%%
for i = 16:num
    % obtain the folder name and subfolder name
    path = [mainFolder,nameMainFolds{i}];
    path = [path,'/'];
    
    dir_name = dir(path); 
    isub = [dir_name(:).isdir]; %# returns logical vector
    nameFolds = {dir_name(isub).name}'; 
    nameFolds(ismember(nameFolds,{'.','..'})) = []; 
    
    for j = 1:length(nameFolds)
        
%% step 1: unzip the nii.gz file
        dirUnzip = dir(fullfile([path,nameFolds{j}],'*.nii.gz'));
        dirOutput = dir(fullfile([path,nameFolds{j}],'*.nii'));
        % If nii is not exist, unzip the nii.gz to nii
        if(isempty(dirOutput))
            gunzip([dirUnzip.folder,filesep,dirUnzip.name]);
        end
        dirOutput = dir(fullfile([path,nameFolds{j}],'*.nii'));
        fileFolder = [dirOutput.folder,'/'];
        disp(i); % Patient's index
        fprintf(' Labeling case is %s\n',nameFolds{j});
%% step 2: load the info and volume V
        
        info = nii_read_header([fileFolder,dirOutput.name]);
        V = nii_read_volume(info);
        info.PixelSpacing=info.PixelDimensions(1:2);
        info.SpacingBetweenSlices=info.PixelDimensions(3);

%% step 3: segment and visualize the image
        
        dirThresh = dir(fullfile([path,nameFolds{j}],'thresh.mat'));
        if(~isempty(dirThresh))
            load([fileFolder,'thresh.mat']); %loading threshold
        end
        
        thresh = 150 ;%(vary from case to case...)
        save([fileFolder,'thresh.mat'],'thresh'); %Saving threshold
              
        figure,
        [h1,h2] =  visibleCube(V,info,thresh,[2 2 1]);   % use [2 2 1] or [1 1 1] for finer resolution
        hold on;
        vertex = h1.Vertices;
        camlight;

%% loading previous labels for visualization if available
        dirLabel = dir(fullfile([path,nameFolds{j}],'label.mat'));
        if(~isempty(dirLabel))
            SPosition = load([fileFolder,'label.mat']);
            PosName = fieldnames(SPosition);
            for k =1:length(PosName)
                Fid = getfield(SPosition,PosName{k});
                for nPoint =1:length(Fid)
                    if(PosName{k}=='sp') % Use red color to indicate spinous process(middle), blue to indicate transverse process
                        scatter3(Fid(nPoint).Position(1),Fid(nPoint).Position(2),Fid(nPoint).Position(3),200,[1 0 0],'filled');
                    else
                        scatter3(Fid(nPoint).Position(1),Fid(nPoint).Position(2),Fid(nPoint).Position(3),200,[0 0 1],'filled');
                    end
                end
            end
        else
            fprintf('No label for Case %s\n',nameFolds{j});
        end
         clear tp;
         clear sp;

%% step 4: labeled the transverse processes, spinal processes(middle part) of the spine
% name of the file. For example, if you labeling the 'patient0001' in a sub folder name '2804506', then the name of the label file should be 'patient0001_2804506_label.mat'.
        saveName = [nameMainFolds{i},'_',nameFolds{j},'_label.mat'];
        if( exist('tp') && exist('sp')) %%%%%%%%%%%%%%%<= setting the Break point here for labeling
            
            save([fileFolder,saveName],'tp','sp');
        end
        

%% visualize the labels 
        % Loading the labels
        dirLabel = dir(fullfile([path,nameFolds{j}],saveName));
        if(~isempty(dirLabel))
            SPosition = load([fileFolder,saveName]);
            PosName = fieldnames(SPosition);
            
            for k =1:length(PosName)
                Fid = getfield(SPosition,PosName{k});
                
                for nPoint =1:length(Fid)
                    if(PosName{k}=='sp') % Use red color to indicate spinous process, blue to indicate transverse process
                        scatter3(Fid(nPoint).Position(1),Fid(nPoint).Position(2),Fid(nPoint).Position(3),200,[1 0 0],'filled');
                    else
                        scatter3(Fid(nPoint).Position(1),Fid(nPoint).Position(2),Fid(nPoint).Position(3),200,[0 0 1],'filled');
                    end
                end
                
            end
            % save the fig to current folder

           savefig([fileFolder,nameMainFolds{i},'_',nameFolds{j},'_.fig']);
        end

    end %%%%%%%%%%%%%%%<= setting the Break point here for visualizing the labels
end