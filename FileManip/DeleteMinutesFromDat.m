filename = 'R2D2_060915-04.dat';
outfile = 'R2D2_060915-04_cut.dat';
mins = 69; %keep first (this many) minutes of file
numchans = 72; 

samprate = 20000;
filebitsperbyte = 16;

bytes = mins*numchans*60*samprate*filebitsperbyte/8;

%use linux "head" command, it will be faster
eval(['!head -c ' num2str(bytes) ' ' filename ' > ' outfile])