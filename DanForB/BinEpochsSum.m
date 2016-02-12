function binvals = BinEpochsSum(data,datatimes,bins)
%takes in bins, fills values of bins with means of values matching each
%bin, bins not filled are left as NaN

binvals = nan(length(bins),1);
idxs = discretize(datatimes,bins,'IncludedEdge','right');
v = unique(idxs);
v(isnan(v)) = [];
for b = 1:length(v)
    tidxs = idxs==v(b);
    binvals(v(b)) = nansum(data(tidxs));
end