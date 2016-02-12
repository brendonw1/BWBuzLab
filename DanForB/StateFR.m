function [ StateFR_out ] = StateFR(spkObject, intervals, states, restrictinginterval )
% function [ StateFR_out ] = StateFR(spkObject, intervals, states, restrictinginterval )
% Gets firing rates for each cell in each of the specified states
% (based on states specified in "intervals" cell from 
% ConvertStatesVectorToIntervalSets.
% 
%   Detailed explanation goes here
%
%TO DO:
%
%Output:
%   StateFR_out.
%
%
%
%
%Last Updated: 7/14/15
%DLevenstein

%% 
display('State Firing Rate');

numstates = length(states);
numcells = length(spkObject);

%Restrict spkObject,intervals to restrictioninterval
if exist('restrictinginterval','var')
    for i = states
        intervals{i} = intersect(intervals{i},restrictinginterval);
    end
end

StateFR_out = zeros(numcells,numstates);
%For each state - count spikes, count time, get rate.
for s = 1:numstates
    st = states(s);
    statestarts = Start(intervals{st},'s'); 
    stateends = End(intervals{st},'s');
    tottimeinstate = sum(stateends-statestarts);
    
    statespikes = Restrict(spkObject,intervals{st});
    
    for c = 1:numcells
        CellSpikes = Range(statespikes{c},'s');
        StateFR_out(c,s) = numel(CellSpikes)/tottimeinstate;
    end
    
end




% 
% %% Figure: Firing Rate
% 
% figure
%     subplot(3,1,1)
%         hold on
%         imagesc(t,1:numcells,zspikemat(:,sort_rate)')
%         xlabel('t (s)');ylabel('Neuron, sorted by mean firing rate');
%         cb = colorbar;
%         set(get(cb,'Title'),'String','r(t) (Z-score)')
%         axis xy
%         caxis([-3 3])
%         image(t,max(numcells)+[3 4],(scorevec.*10)')
%         xlim([t(1) t(end)]);ylim([0 max(numcells)+4])
%         title(['Recording ',num2str(r),recordings(r).name,' Firing rate with 37.5ms gaussian'])
% 	subplot(3,2,[3,5])
%         plot(log10(FR_wake),log10(FR_SWS),'.b',...
%         log10(FR_wake),log10(FR_REM),'.g',...
%         [-2 1.5],[-2 1.5],'k')
%         xlim([-2 1.5]);ylim([-2 1.5])
%         xlabel('Firing Rate Wake (Hz)');ylabel('Firing Rate Sleep (Hz)');
%         legend('SWS','REM','Location','northwest')
%         set(gca,'XTick',[-2:1])
%         set(gca,'XTickLabel',num2cell(10.^(-2:1)))
% 
% saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_FR'],'jpeg')
% 
% 



end

