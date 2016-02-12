function d = getdropbox

[~,cname]=system('hostname');
if strcmp(cname(1:9),'Mac176698')%if I'm on my laptop
    d = '/Users/brendon/Dropbox';
else %ie if at lab
    d = '/mnt/brendon4/Dropbox';
end
