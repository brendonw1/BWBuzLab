function [spikemat,t,spindices] = SpktToSpkmat(spiketimes, T, dt,overlap)
%SpktToSpkmat(spiketimes,T, dt) takes a 1 x N_neurons cell array of spiketimes 
%and converts into a t/dt x N spike matrix.
%
%INPUTS
%Options for T:
%T = [t_end]
%T = [t_start t_end]                %For additional start time (t_start<0)
%T = [t_start t_offset t_end]       %If t=0 is at aribtrary time t_offset
%
%Overlap = if want to multiple count spikes in overlapping bins.
%   Note: overlap should be even... fix this
%
%Return:
%Spike Matrix
%time vector
%Spike time/cell indices for plotting
%
%To Do:
%   -Remove for loop... don't need to go through structure.
%   -T is just silly... make this a reasonable time window able to select
%   only spikes within a given time
%
%
%Last Updated: 9/25/15
%DLevenstein


numcells = length(spiketimes);
if numcells == 0
    spikemat=[];t=[];spindices=[];
    return
end

if isa(spiketimes,'tsdArray')
    for c = 1:numcells
        spiketimestemp{c} = Range(spiketimes{c},'s');
    end
    spiketimes = spiketimestemp;
    clear spiketimestemp
end

if length(T) == 1
    t_start = 0; t_offset = 0; t_end = T;
elseif length(T) == 2
    t_start = T(1); t_offset = 0; t_end = T(2);
elseif length(T) == 3
    t_start = T(1); t_offset = T(2); t_end = T(3);
elseif length(T) == 0;
    t_start = 0; t_offset = 0; t_end = max(vertcat(spiketimes{:}));
else
    display('T must be 1 2 or 3 elemements or 0')
end



numts = ceil((t_end-t_start)/dt);

%Remove spikes after t_end and before t_start (t_offset+t_start)
absendtime = t_offset+t_end;
absstarttime = t_offset+t_start;
spiketimes = cellfun(@(x) x(find(x<absendtime)),spiketimes,'UniformOutput',false);
spiketimes = cellfun(@(x) x(find(x>absstarttime)),spiketimes,'UniformOutput',false);


%Establish Cell Structure... maybe do this with cellfun... or
%cell2struct
cells = cell2struct(spiketimes,'spiketimes',1);
for cell_ind = 1:numcells
    %When Spike? row index for each spike
    cells(cell_ind).spiketimes = cells(cell_ind).spiketimes'-t_offset;
    %Which Cell? column index for each spike
    cells(cell_ind).index4spikes = cell_ind*ones(size(cells(cell_ind).spiketimes));
end

%Make a Spike Matrix
spikemat = zeros(numts,numcells);
%Spike Indices - time
spikes_ind_t = ceil(([cells.spiketimes]-t_start)/dt); 
spikes_ind_t(find(spikes_ind_t==0)) = 1;
%Spike Indices - cell
spikes_ind_c = [cells.index4spikes];

%Recount in overlapping bins for "boxcar" style (needed for MUAhist)
if exist('overlap','var')
    spikes_ind_c = repmat(spikes_ind_c,1,overlap);
    spikes_ind_t_temp = [];
    for o = 1:overlap
        spiketimeoffset = o-ceil(overlap/2);
        spikes_ind_t_temp = [spikes_ind_t_temp spikes_ind_t+spiketimeoffset];
    end
    spikes_ind_t = [];
    spikes_ind_t = spikes_ind_t_temp;
    %Remove negative t or overhanging spikes
    spikes_ind_c(find(spikes_ind_t<=0 |spikes_ind_t>=numts)) = [];
    spikes_ind_t(find(spikes_ind_t<=0 |spikes_ind_t>=numts)) = [];
end

%Spike Indices - convert to linear index
spikes_ind = sub2ind(size(spikemat), spikes_ind_t,spikes_ind_c);

%Add Spikes to bins
while spikes_ind
    spikemat(spikes_ind) = spikemat(spikes_ind)+1;
    %Remove full bins
    [uniquespikes, unisp_ind] = unique(spikes_ind);
    spikes_ind(unisp_ind) = [];
end

t = [0:size(spikemat,1)-1]'*dt+0.5*dt+t_start; %time vector (midpoint)

spindices = [[cells.spiketimes]',[cells.index4spikes]'];


end

