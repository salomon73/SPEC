function volume = get_spec_volume(data,lvol,ns,nt,nz)
 
%
% GET_SPEC_VOLUME( DATA, LVOL, NS, NT, NZ )
% =========================================
%
% Calculates volume of a given volume lvol
%
% INPUT
% -----
%   -data    : must be produced by calling read_spec(filename)
%   -lvol    : volume number
%   -ns      : is the resolution in the s-coordinate     (e.g. 64)
%   -nt      : is the resolution in the theta-coordinate (e.g. 64)
%   -nz      : is the resolution in the zeta-coordinate  (e.g. 64)
%
% OUTPUT
% ------
%   -volume  : volume in m^3 if geometrical dimensions (R,Z) are interpreted in meters.
%
% Note: Stellarator symmetry is assumed
%
% written by J.Loizu (2016)


sarr     = linspace(-1,1,ns);
tarr     = linspace(0,2*pi,nt);
zarr     = linspace(0,2*pi,nz);

jacobian = get_spec_jacobian(data,lvol,sarr,tarr,zarr);

volume   = sum(sum(sum(jacobian(2:end,:,:))))*(2*2*pi*2*pi)/(ns*nt*nz);
