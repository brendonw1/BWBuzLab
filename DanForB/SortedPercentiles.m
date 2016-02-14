function [ datapercmean,datapercstd,datapercraw ] = SortedPercentiles(data,sortorder,numdistbins)
%SortedPercentiles(data,sort,numperc) averages data into equal number of
%bins as ordered by sortorder.
%
%
%
%Last Updated: 10/8/15
%DLevenstein
%%

numcells = length(data(1,:));

numperc = numcells/numdistbins;
percentilefloor = floor(linspace(1,numcells,numdistbins+1));
percentileceil = ceil(linspace(1,numcells,numdistbins+1));

numtbins = length(data(:,1));
datapercraw = {};
datapercmean = zeros(numtbins,numdistbins);
datapercstd = zeros(numtbins,numdistbins);
data = data(:,sortorder);
for d = 1:numdistbins
    datapercraw{d} = data(:,percentileceil(d):percentilefloor(d+1));
    datapercmean(:,d) = nanmean(datapercraw{d},2);
    datapercstd(:,d) = nanstd(datapercraw{d},[],2);
end


end
