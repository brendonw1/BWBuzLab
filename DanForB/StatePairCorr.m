function [ StatePairCorr_out ] = StatePairCorr( spkObject, intervals, states, restrictinginterval )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%
%Options: Bins or Smooth.   note: 100ms bin looks very similar to 37.5ms
%gauss. as expected by Kruskal et al 2007
%
%
%
%Last Updated: 7/14/15
%DLevenstein


%% 
display('Pairwise Correlations')

%Parms
dt = 0.1;
width = 0.0375;


numcells = length(spkObject);
numstates = length(states);

for c = 1:numcells
    CellSpikes{c} = Range(spkObject{c},'s');
end

    
%Convert Spiketimes to a spike matrix and z-score
T = [0 max(vertcat(CellSpikes{:}))];
[spikemat,t] = SpktToSpkmat(CellSpikes, T, dt);
%For Smooth... add as parms option later
%[spikemat,t] = SpktToRate(CellSpikes,width,T,dt);

%Restrict spkObject,intervals to restrictioninterval
if exist('restrictinginterval','var')
    for i = states
        intervals{i} = intersect(intervals{i},restrictinginterval);
    end
end
    
    
%Make Score vector and get corr - this is convoluted..... but works
scorevec = zeros(size(t));
corrmat = zeros(numcells,numcells,numstates);
for st = 1:numstates
    s = states(st);
    statestarts = Start(intervals{s},'s'); 
    stateends = End(intervals{s},'s');
        for e = 1:length(statestarts)
            stateind = find(t>statestarts(e) & t<stateends(e));
            scorevec(stateind) = s;
        end
    tempcorr = corr(spikemat(scorevec==s,:));
    %Set Diagonals to 1 and any NaNs to 0 (if cell fires no spikes in a
    %state...)
    tempcorr(isnan(tempcorr))= 0;
    tempcorr(logical(eye(size(tempcorr)))) = 1;
    
    corrmat(:,:,st) = tempcorr;
end




StatePairCorr_out = corrmat;

%%
% %% Figure: Pairwise Correlations
% colorrange = [-0.25 0.25];
% 
% figure
%      subplot(3,3,1)
%         imagesc(corrmat_wake(sort_rate,sort_rate))
%         caxis(colorrange)
%         title('Wake')
%         colorbar
%         xlabel('Neuron, Sorted by mean firing rate');
%         ylabel('Neuron, Sorted by mean firing rate');
%      subplot(3,3,2)
%         imagesc(corrmat_SWS(sort_rate,sort_rate))
%         caxis(colorrange)
%         title('SWS')
%         colorbar
%         xlabel('Neuron, Sorted by mean firing rate');
%         ylabel('Neuron, Sorted by mean firing rate');
%      subplot(3,3,3)
%         imagesc(corrmat_REM(sort_rate,sort_rate))
%         caxis(colorrange)
%         colorbar
%         title('REM')
%         xlabel('Neuron, Sorted by mean firing rate');
%         ylabel('Neuron, Sorted by mean firing rate');
% %      subplot(3,12,15)
% %         plot(log10(FR_whole(sort_rate)),1:numcells,'.k')
% %         ylim([0 numcells]);xlim(log10([min(FR_whole) max(FR_whole)]));
% %         set(gca,'YDir','Reverse')
% %         xlabel('Log Firing Rate');ylabel('Cell, Ordered by Firing Rate')
% 
%     subplot(3,3,5)
%         imagesc(corrmat_SWS(sort_rate,sort_rate)-corrmat_wake(sort_rate,sort_rate))
%         caxis(colorrange)
%         colorbar
%         title('SWS-wake')
%         xlabel('Neuron, Sorted by mean firing rate');
%         ylabel('Neuron, Sorted by mean firing rate');
%         
%     subplot(3,3,6)
%         imagesc(corrmat_REM(sort_rate,sort_rate)-corrmat_wake(sort_rate,sort_rate))
%         caxis(colorrange)
%         colorbar
%         title('REM-wake')
%         xlabel('Neuron, Sorted by mean firing rate');
%         ylabel('Neuron, Sorted by mean firing rate');
%         
%     subplot(3,3,9)
%         imagesc(corrmat_REM(sort_rate,sort_rate)-corrmat_SWS(sort_rate,sort_rate))
%         caxis(colorrange)
%         colorbar
%         title('REM-SWS')
%         xlabel('Neuron, Sorted by mean firing rate');
%         ylabel('Neuron, Sorted by mean firing rate');
% 
%     subplot(2,3,4)
%         plot(sum(corrmat_wake),sum(corrmat_SWS),'b.',...
%             sum(corrmat_wake),sum(corrmat_REM),'g.',...
%             [-0.5 3],[-0.5 3],'k')
%         xlabel('Node Strength Wake');ylabel('Node Strength Sleep');
%         legend('SWS','REM','Location','southeast')
% 
% saveas(gcf,['SWSWREM_AllRecs/',recordings(r).name,'_Corr'],'jpeg')        



end

