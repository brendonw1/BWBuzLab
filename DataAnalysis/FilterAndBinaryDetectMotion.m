function [movementsecs,varargout] = FilterAndBinaryDetectMotion(motion,filttype,filtwidth,plotting)
% Takes motion signal at 1second resolution (ie from StateEditor) and
% zscores/filters/subtracts to allow for binary detection of motion on a
% smooth background
% INPUT
% motion: vector of 1 second long bins of motion measure
%
% OUTPUT
% movementsecs - logical output of 1's where movement detected (at
%                0.75*sd), 0s where no movement


if ~exist('filttype','var')
    filttype = 'cleansig';%default
end
if ~exist('filtwidth','var')
    filtwidth = 20;%default, in timepoints(seconds if 1hz file)
end

if ~exist('plotting','var')
    plotting = 0;
end

fm = filtermotionsig(motion,filtwidth);

switch filttype
    case 'clean'
        % hardthresh = -mean(zf(zf<0));
        tm = fm>.75;
    case 'noisybaseline'
                %gonna zscore in a weird way: first use mode, not mean, then divide by sd
        %of noise below that modal value... assumes symmetrical noise
        fm = fm-mode(fm);%subtract mode
        negdist = fm(fm<0);%get negative part of distribution
        negdist = cat(1,negdist,-negdist);%make a reflection about zero to double this half-gaussian
        snd = std(negdist);%get the SD of this noise
        zf = fm/snd;%divide the signal by the sd of this noise

        % hardthresh = -mean(zf(zf<0));
        tm = zf>10;
        tm = tm + [0;tm(2:end)];
        % tm = tm>=2;
end
        
movementsecs = tm;

if plotting
    h = figure;
    zm = zscore(motion);
    plot(zm);
    hold on;
    plot(movementsecs,'r')
    if nargout ==2;
        varargout{1} = h;
    end
end