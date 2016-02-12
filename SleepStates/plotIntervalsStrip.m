function plotIntervalsStrip(ax,intervals,scalingfactor)
% Plots colorized states (from StateEditor) on the top of the current
% graph.  From stateintervals variable in _StateIDM.mat files.
% ax - axes on which to plot
% intervals - intervals from ConvertStatesVectorToIntervalSets
% scaling factor = samples per second (baseline is 1, not 10000)

hold on

yl = get(ax,'YLim');
linewidth = abs(diff(yl))*0.15;
y = yl(2);
ylim([yl(1) yl(2)+linewidth])

% colorwheel = [[0 0 0];...
%     [255, 236, 79]/255;...
%     [6, 113, 148]/255;...
%     [19, 166, 50]/255;...
%     [207, 46, 49]/255];
colorwheel = [[0 0 0];...
    [6, 113, 148]/255;...
    [207, 46, 49]/255];

for a = 1:3 %for each class of interval
    ti = intervals{a}; 
    for b = 1:length(length(ti));
        thisint = scalingfactor*[StartEnd(subset(ti,b),'s')];
        patch([thisint(1) thisint(1) thisint(2) thisint(2)],[y y+linewidth y+linewidth  y],colorwheel(a,:),'edgecolor',colorwheel(a,:))
    end
end