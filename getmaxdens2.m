function [maxdens,times,positions] = getmaxdens2(tinicial,tfinal,npoints)

tic;
interval = (tfinal-tinicial)/(npoints-1);

times     = zeros(npoints,1);
positions = zeros(npoints,1);
maxdens   = zeros(npoints,1);
previdx = 0;
fid=fopen('b2y280xC_25.txt','a+');
for i = 1:npoints
    time = tinicial + interval*(i-1);
    
    [coords,maxvrble,currtime,fileidx] = getmaxvarinregion(time,-5e10,5e10,2.e9,6.e10,0,'magz')

    fprintf(fid, '%4d    %0.2f    %0.2f      %e \n', [time coords*1.e-8 maxvrble]);
    %szcrds = max(size(coords));
    
    %[maxdens(i),idpos] = max(maxvrble(ceil(szcrds/2):szcrds));
    %positions(i) = coords(idpos+ceil(szcrds/2));
    %times(i) = currtime;
    %previdx = max([0,fileidx-1]);
end
toc;
