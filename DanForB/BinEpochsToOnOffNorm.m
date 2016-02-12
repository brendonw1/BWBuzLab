function [on_binned, off_binned, norm_binned, onbins, offbins, normbins] = ...
    BinEpochsSumToOnOffNorm(epochdatapoints, epochsamptimes, int, sampfreq, tbins4norm, sampoverhangs)
%epochs will have arbitrary starts and ends.  Need to be synchronized an
%sampled at a synchronized set of bins, then output as values per bin.
%Each epoch is a collection of datapoints and sample times, which
%correpsond to each other... vector1 of epochdatapoints matches vector1 of
%epochsamptimes.  Binwidth set by 1/sampfreq.

ne = length(epochdatapoints);

%find first start and last end of while collection of epoch
% for a = 1:ne
%    s(a) = min(epochsamptimes{a});
%    e(a) = max(epochsamptimes{a});
% end
% 
% S = min(s);
% E = max(e);

sampfreq = 1/sampfreq;
intlengths = int(:,2)-int(:,1);
overhanglength = max(sampoverhangs);
maxintlength = max(intlengths);

%generally will make the longest spans necessary to include the longest
%intervals and overhangs and for each epoch will leave as NaN any bins not
%populated by that epoch
% will make canonical bins, centered at zero up here, then offset them 
% inside the loop to match the start/end of each epoch

%onsetbins: longest overhang then longest interval length
b1 = fliplr(0:-sampfreq:-overhanglength);
b2 = sampfreq:sampfreq:maxintlength;
onbins = [b1 b2];
%offset bins: longest interval then longest overhang
b1 = fliplr(0:-sampfreq:-maxintlength);
b2 = sampfreq:sampfreq:overhanglength;
offbins = [b1 b2];
%norm bins: tbins4norm populate the interval.  Find the points per second
%for each epoch that this equals and propagate bins outward from edges too
%using the same size bins... will do this inside the loop
% normbinsecs = intlengths./tbins4norm;%list of seconds/bin for each epoch
normbins = linspace(-1,2,3*tbins4norm+1);%multiply this by above then 
                                         %offset for each epoch

on_binned = [];
off_binned = [];
norm_binned = [];
                                         
for a=1:ne
    tstart = int(a,1);
    tend = int(a,2);
    %for onset-locked
    tonbins = onbins+int(a,1);%move the zero to int start
    toffbins = offbins+int(a,2);%move the zero int end
    tnormbins = (normbins*intlengths(a))+int(a,1);%multiply to match 
        % total seconds in the interval, then scoot the zero to int start
    
    on_binned(:,a) = BinEpochs(epochdatapoints{a}, epochsamptimes{a}, tonbins);
    off_binned(:,a) = BinEpochs(epochdatapoints{a}, epochsamptimes{a}, toffbins);
    norm_binned(:,a) = BinEpochs(epochdatapoints{a}, epochsamptimes{a}, tnormbins);
end


1;
