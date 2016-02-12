filename = 'Rizzo_022315-05.dat';
numchans = 133;

removechannels = [65:128];
bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2

fidr = fopen(filename,'r');
fidw = fopen('Rizzo_022315-05_NEW.dat','w+');

fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
numsamps = filebytes/numchans;

fseek(fidr,0,'bof');
fseek(fidw,0,'bof');

if ~mod(numsamps,1)==0 %if a non-integer number
    disp('Non-integer number of samples in file')
else %otherwise, if integer
    for a = 1:numsamps
    %     startofsamp = ((a-1)*bytespersamp*numchans)+1;
    %     fseek(fidr,'bof',startofsamp);
        samples = fread(fidr,numchans,'int16');
    %     frewind(fidr);

        samples(removechannels)=[];

        fwrite(fidw,samples,'int16');
%         disp([num2str(a),' out of ',num2str(numsamps)])
        %h = waitbar(a/length(numsamps));
    end
end

fclose(fidr);
fclose(fidw);