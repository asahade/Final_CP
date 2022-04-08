function [filename,nxb,nyb,nzb,ndim,xmin,xmax,ymin,ymax,zmin,zmax] = geth5data

path = 'b2y280x2fC/';
  %
  %Documentos/datosPoster/Bi00/
file = 'AAA_cme_';


pltstring = 'hdf5_plt_cnt_';
chkstring = 'hdf5_chk_'

% Extraer datos de la malla
%filename = strcat(path,file,chkstring);
filename = strcat(path,file,pltstring);
filename0 = strcat(filename,'0000');

intgrsclrs = h5read(filename0,'/integer scalars');
nblocks = intgrsclrs.value(5);  % Número total de bloques
nxb  = intgrsclrs.value(1);     % Número de celdas en x
nyb  = intgrsclrs.value(2);     % Número de celdas en y
nzb  = intgrsclrs.value(3);     % Número de celdas en z
ndim = intgrsclrs.value(4);     % Número de dimensiones del problema

rlsclrs =  h5read(filename0,'/real scalars');
time = rlsclrs(1);

boundbox = h5read(filename0,'/bounding box');

xmin = min(boundbox(1,1,:));    xmax = max(boundbox(2,1,:));
ymin = min(boundbox(1,2,:));    ymax = max(boundbox(2,2,:));
zmin = min(boundbox(1,3,:));    zmax = max(boundbox(2,3,:));

