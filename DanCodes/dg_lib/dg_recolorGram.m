function hCB_new = dg_recolorGram(hCB_old, clim, hI)
%hCB_new = dg_recolorGram(hCB_old, clim, hI)
% Companion function to dg_showGram.
% hCB_old: handle to old colorbar axes
% clim: 2-element array to use as new 'CLim' value
% hI: handle to imagesc image object
% hCB_new: handle to newly created colorbar (the old one gets destroyed)
%hCB_new = dg_recolorGram('current', clim)
% Finds hCB_old and hI in current figure.

% Resets the color scale of an imagesc image and its associated colorbar to
% <clim>, preserving the labelling of the colorbar.

%$Rev: 174 $
%$Date: 2013-05-01 18:46:08 -0400 (Wed, 01 May 2013) $
%$Author: dgibson $

if isequal(hCB_old, 'current')
    hA = findobj(gcf, 'Type', 'Axes');
    hCB_old = hA(1);
    hA = hA(2);
else
    hA = get(hI, 'Parent');
end
if diff(clim) < 0
    clim = clim([2 1]);
end
set(hA, 'CLim', clim);
cbarlabel = get(get(hCB_old, 'YLabel'), 'String');
oldCBposition = get(hCB_old, 'Position');
oldGramPosition = get(hA, 'Position');
delete(hCB_old);
hCB_new = colorbar('peer', hA, 'Position', oldCBposition);
set(get(hCB_new,'YLabel'), 'String', cbarlabel);
set(hA, 'Position', oldGramPosition);

