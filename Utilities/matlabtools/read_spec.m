function data = read_spec(filename)
  
% Reads the HDF5 output file produced by SPEC
%
% INPUT
% -  filename : path to the HDF5 output file (e.g. 'testcase.h5')
%
% OUTPUT
% -  data     : contains all data from the SPEC run, which can be fed into several routines for analyzing and plotting
%
% written by J.Schilling (2019)
% based on the routines by J.Loizu and read_hdf5.m by S. Lazerson

% Try to read the file first
try
    data_info = h5info(filename,'/');
catch h5info_error
    data=-1;
    disp(['ERROR: Opening HDF5 File: ' filename]);
    disp(['  -identifier: ' h5info_error.identifier]);
    disp(['  -message:    ' h5info_error.message]);
    disp('      For information type:  help read_hdf5');
    return
end

% recursive reading routine
function g_data = getGroup(filename, root)
  g_data_info = h5info(filename, root);
  ngroups     = length(g_data_info.Groups);
  nvars       = length(g_data_info.Datasets);
  % Get datasets in root node
  for i = 1: nvars
    g_data.([g_data_info.Datasets(i).Name]) = h5read(filename,[root '/' g_data_info.Datasets(i).Name]);
    natts = length(g_data_info.Datasets(i).Attributes);
    for j=1:natts
        g_data.([g_data_info.Datasets(i).Attributes(j).Name]) = g_data_info.Datasets(i).Attributes(j).Value{1};
    end
  end
  % get groups in root node
  if ngroups > 0
    for i = 1 : ngroups
      g_path = strsplit(g_data_info.Groups(i).Name, '/');
      g_data.([g_path{end}]) = getGroup(filename, g_data_info.Groups(i).Name);
    end
  end
end

% start recursion at root node
data = getGroup(filename, '/');

% make adjustments for compatibility with previous reading routines
Nvol = data.input.physics.Nvol;
Lrad = data.input.physics.Lrad;

% vector potential
cAte = cell(Nvol,1);
cAto = cell(Nvol,1);
cAze = cell(Nvol,1);
cAzo = cell(Nvol,1);

% grid
cRij = cell(Nvol,1);
cZij = cell(Nvol,1);
csg  = cell(Nvol,1);
cBR  = cell(Nvol,1);
cBp  = cell(Nvol,1);
cBZ  = cell(Nvol,1);

% split into separate cells for nested volumes
start=1;
for i=1:Nvol
  % vector potential
  cAte{i} = data.vector_potential.Ate(start:start+Lrad(i),:);
  cAto{i} = data.vector_potential.Ato(start:start+Lrad(i),:);
  cAze{i} = data.vector_potential.Aze(start:start+Lrad(i),:);
  cAzo{i} = data.vector_potential.Azo(start:start+Lrad(i),:);

  % grid
  cRij{i} = data.grid.Rij(start:start+Lrad(i),:)';
  cZij{i} = data.grid.Zij(start:start+Lrad(i),:)';
  csg{i}  = data.grid.sg(start:start+Lrad(i),:)';
  cBR{i}  = data.grid.BR(start:start+Lrad(i),:)';
  cBp{i}  = data.grid.Bp(start:start+Lrad(i),:)';
  cBZ{i}  = data.grid.BZ(start:start+Lrad(i),:)';

  % move along combined array dimension
  start = start + Lrad(i)+1;
end

% replace original content in data structure
data.vector_potential.Ate = cAte;
data.vector_potential.Ato = cAto;
data.vector_potential.Aze = cAze;
data.vector_potential.Azo = cAzo;

data.grid.Rij = cRij;
data.grid.Zij = cZij;
data.grid.sg = csg;
data.grid.BR = cBR;
data.grid.Bp = cBp;
data.grid.BZ = cBZ;

% remove unsuccessful Poincare trajectories
data.poincare.R = data.poincare.R(:,:,data.poincare.success==1)
data.poincare.Z = data.poincare.Z(:,:,data.poincare.success==1)
data.poincare.t = data.poincare.t(:,:,data.poincare.success==1)
data.poincare.s = data.poincare.s(:,:,data.poincare.success==1)

end
