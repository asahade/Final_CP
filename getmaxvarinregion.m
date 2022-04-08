function [coords,maxvrble,currtime,fileidx] = ...
    getmaxvarinregion(time,xl,xr,yl,yr,startidx,varname)

% Obtener el máximo valor de la variable "varname" para el tiempo "time" en la región
% delimitada por xl, xr, yl, yr

% "staridx" es el número de archivo a partir se busca el resultado correspondiente
% al tiempo "time". Si no se especifica, se comienza desde cero
 if ~exist('staridx','var')
       staridx = 0;
 end


[filename,nxb,nyb,nzb,ndim,xmin,xmax,ymin,ymax,zmin,zmax] = geth5data;

if (ndim ~= 2)
    disp('Error: La funcion es válida sólo para dos dimensiones')
    return
end

if ((xl >= xr || yl >= yr) ...
        || xr < xmin || xl > xmax || yr < ymin || yl > ymax)
    disp('Error: Los límites de la región a considerar no son válidos.')
    return
end

%str = sprintf ('%e %e',[xl xr]);
%disp (str)

h5var = strcat('/',varname);

for i = startidx:9999
    ichar = num2str(i,'%4i')
    if      (i > 999); currfile = strcat(filename,ichar);
    elseif  (i > 99); currfile = strcat(filename,'0',ichar);
    elseif  (i > 9); currfile = strcat(filename,'00',ichar);
    else   currfile = strcat(filename,'000',ichar);
    end
    
    if exist(currfile,'file')
        rlsclrs =  h5read(currfile,'/real scalars');
        currtime = double(rlsclrs.value(1));
        nxb = double(nxb);
        nyb = double(nyb);
        
        if (currtime >= time)
            intgrsclrs = h5read(currfile,'/integer scalars');
            intgrprmtrs = h5read(currfile,'/integer runtime parameters');
            boundbox = double(h5read(currfile,'/bounding box')); % Límites físicos de los bloques            
                        
            dirx = 1;
            diry = 2;
            
            if (max(size(intgrprmtrs.value)) < 70) % Grilla uniforme
                
                cellx = (boundbox(2,dirx) - boundbox(1,dirx))/nxb;
                coordsx = boundbox(1,dirx)+cellx/2:cellx:boundbox(2,dirx);
                celly = (boundbox(2,diry) - boundbox(1,diry))/nyb;
                coordsy = boundbox(1,diry)+celly/2:celly:boundbox(2,diry);

                [dummy,idxxl] = min(abs(coordsx - xl));
                [dummy,idxxr] = min(abs(coordsx - xr));
                [dummy,idxyl] = min(abs(coordsy - yl));
                [dummy,idxyr] = min(abs(coordsy - yr));

                dum = double(h5read(currfile,h5var));
                maxvrble = 0.;

                for ix = idxxl:idxxr
                    for iy = idxyl:idxyr
                    
                        if dum(ix,iy,1) > maxvrble
                            maxvrble = dum(ix,iy,1);
                            coords = [coordsx(ix), coordsy(iy)];
                        end

                    end
                end

            else  % Malla adaptativa

                nblocks = intgrsclrs.value(5);  % Número total de bloques
                reflevel = h5read(currfile,'/refine level'); % nivel de refinamiento de cada bloque
                        
                maxvrble = 0.;
                dum = abs(double(h5read(currfile,h5var)));

                for nb = 1:nblocks-1
                    if (reflevel(nb) >= reflevel(nb+1))
                        
                        xlb = boundbox(1,dirx,nb);
                        xrb = boundbox(2,dirx,nb);
                        ylb = boundbox(1,diry,nb);
                        yrb = boundbox(2,diry,nb);


                        if ((xlb < xr && xrb > xl) && (ylb < yr && yrb > yl))

                            cellx = (boundbox(2,dirx,nb) - boundbox(1,dirx,nb))/nxb;
                            coordsx = boundbox(1,dirx,nb)+cellx/2:cellx:boundbox(2,dirx,nb);
                            celly = (boundbox(2,diry,nb) - boundbox(1,diry,nb))/nyb;
                            coordsy = boundbox(1,diry,nb)+celly/2:celly:boundbox(2,diry,nb);

                            [dummy,idxxl] = min(abs(coordsx - xl));
                            [dummy,idxxr] = min(abs(coordsx - xr));
                            [dummy,idxyl] = min(abs(coordsy - yl));
                            [dummy,idxyr] = min(abs(coordsy - yr));

                            for ix = idxxl:idxxr
                                for iy = idxyl:idxyr
                    
                                    if dum(ix,iy,1,nb) > maxvrble
                                        maxvrble = dum(ix,iy,1,nb);
                                        coords = [coordsx(ix), coordsy(iy)];

                                    end

                                end
                            end
                        end
                    end
                end
            end
            fileidx = i;
            break
        end
    else
        break
    end
    
end

    
