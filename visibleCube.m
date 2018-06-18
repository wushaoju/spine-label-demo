function [hiso,hcap]=visibleCube(stack,stackInfo,isoV,Nxyz,argin)
% function [hiso,hcap]=visibleCube(stack,stackInfo,isoV,Nxyz [,argin])
% 
% Program that visualize the MR/CT stack object outer boundary based on
% specified iso-value (isoV).  Optionally, specify 3 integers Nxyz (default
% of [1 1 1]) to scale down the image/stack size to speed up processing.
% Note that large N "melts" the object.  Recommend Nxyz=[2 2 1] (so that
% amount of data is roughly 1/(2*2*1) (for 3D) the origional size.  When
% stackInfo has MR/CT registratoin info, the marker locations are also
% plotted (specific to the brain project).
% 
% 
% First version by Songbai Ji 07/02/2006.
% Songbai Ji 07/11/2006: added two output arguments.
% Added function help header 08/26/2006.
% (Songbai Ji 11/20/2006) Now support different scaling factor in X, Y, and
%     Z directions.  Also, the resulted isosurface/isocaps are in the
%     correct physical coordinate system (unit in mm, as in dicom header).
% Songbai Ji 1/13/2007.  Added support to have user control the smooth
%     parameters other than the default ('argin'). e.g.,:
%     [hiso,hcap]=visibleCube(stack,stackInfo,isoV,Nxyz, {'box',5});
% 
% Songbai Ji, 9/29/2009. Bug fixed (starting voxel location incorrect for D).

%% check input
if nargin <3
    Nxyz = [1 1 1];  %% MR image scale factor
    isoV = 10;
elseif nargin <4
    Nxyz = [1 1 1];
elseif nargin == 2
	if size(Nxyz ~= 3); error('size of Nxyz must be 3!'); end
	if any(Nxyz<0); error('Nxyz must be positive!'); end
	
elseif nargin <2
    error('must provide image stack and stackInfo!');
end
ProbeLength = 0.20;  %% simulated probe length used to indicate MR markers

%% scale input 
D = stack(Nxyz(2):Nxyz(2):end, Nxyz(1):Nxyz(1):end, ...
    Nxyz(3):Nxyz(3):end); % NOTE, x refer to col, y refer to row
clear stack  % it's not needed any more

if exist('argin','var');
    Ds = smooth3(D,argin{:});   % smooth the input
else
    Ds = smooth3(D);
end

%% visualization stuff
figure(gcf);
hiso = patch(isosurface(Ds,isoV),...
'FaceColor',[1,.75,.65],...
'EdgeColor','none');
set(hiso, 'tag', 'isosurface');

hcap = patch(isocaps(Ds,isoV),...
'FaceColor','interp',...
'EdgeColor','none');
set(hcap,'tag', 'isocap');

% lightangle(45,30);
% set(gcf,'Renderer','zbuffer'); lighting phong;
% isonormals(Ds,hiso);
% set(hcap,'AmbientStrength',.6)
% set(hiso,'SpecularColorReflectance',0,'SpecularExponent',50)

%% now scale properly to retain correct size:
nod=get(hiso,'vertices');
if ~isempty(nod)
    set(hiso,'vertices',[ nod(:,1)*Nxyz(1)*stackInfo.PixelSpacing(1), ...
        nod(:,2)*Nxyz(2)*stackInfo.PixelSpacing(2), ...
        nod(:,3)*Nxyz(3)*stackInfo.SpacingBetweenSlices ]);
end
nod=get(hcap,'vertices');
if ~isempty(nod)
    set(hcap,'vertices',[ nod(:,1)*Nxyz(1)*stackInfo.PixelSpacing(1), ...
        nod(:,2)*Nxyz(2)*stackInfo.PixelSpacing(2), ...
        nod(:,3)*Nxyz(3)*stackInfo.SpacingBetweenSlices ]);
end

view(45,30);  axis tight; axis equal;


%% the following is specific to the brain project visualization
% now plot reg points:
if isfield(stackInfo, 'RegPoints')
    nPnts = length(stackInfo.RegPoints);
    regPoints = zeros(nPnts, 3); %% x,y,z
    for i = 1 : nPnts
        regPoints(i,:) = stackInfo.RegPoints(i).Point;
    end

	regPoints = [regPoints(:,1)*stackInfo.PixelSpacing(1), ...
		regPoints(:,2)*stackInfo.PixelSpacing(2), ...
		regPoints(:,3)*stackInfo.SpacingBetweenSlices ];

    hold on;
	
    %get the centroid
    xlim=get(gca,'XLim'); ylim=get(gca,'YLim'); zlim=get(gca,'ZLim');
    centroid = [mean(xlim), mean(ylim), mean(zlim)];

    v = regPoints-repmat(centroid, nPnts,1);
    % get the normal
    vv = v.*v;
    vv = sqrt(sum(vv, 2));
    n = v./repmat(vv,1,size(v,2));

    endPoints = regPoints + ProbeLength*(max(xlim)-min(xlim))*n;
    hd = plot3([regPoints(:,1), endPoints(:,1)]', [regPoints(:,2), endPoints(:,2)]', ...
        [regPoints(:,3), endPoints(:,3)]', 'r','linewidth',5);
    set(hd,'tag','regPoints');
end