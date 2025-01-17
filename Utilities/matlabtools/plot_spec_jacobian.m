function rzbdata = plot_spec_jacobian(data,lvol,sarr,tarr,zarr,newfig)

%
% PLOT_SPEC_JACOBIAN( DATA, LVOL, SARR, TARR, ZARR, NEWFIG )
% ==========================================================
%
% Produces plot of sqrt(g) in (R,Z,zarr) cross-section(s)
%
% INPUT
% -----
%   -data    : data obtained via read_spec(filename)
%   -lvol    : volume number
%   -sarr    : is the array of values for the s-coordinate ('d' for default)
%   -tarr    : is the array of values for the theta-coordinate ('d' for default)
%   -zarr    : is the array of values for the zeta-coordinate ('d' for default)
%   -newfig  : opens(=1) or not(=0) a new figure, or overwrite existing one
%   (=2)
%
% OUTPUT
% ------
%   -rzbdata : cell structure with 3 arrays: R-data, Z-data, |B|-data
%
% written by J.Loizu (2016)

if(sarr=='d')
sarr=linspace(-1,1,64);
end

if(tarr=='d')
tarr=linspace(0,2*pi,64);
end

if(zarr=='d')
zarr=0;
end

rzbdata = cell(3);

% Compute sqrt(g)

jac   = get_spec_jacobian(data,lvol,sarr,tarr,zarr);

% Compute function (R,Z)(s,theta,zeta)

rzdata = get_spec_rzarr(data,lvol,sarr,tarr,zarr);

R = rzdata{1};   
Z = rzdata{2};

% Plot

switch newfig
    case 0
        hold on
    case 1
        figure
        hold on
    case 2
        hold off
end

Rtemp = R;
Ztemp = Z;
switch data.input.physics.Igeometry
    case 1
        R = tarr;
        Z = Rtemp;
    case 2
        for it=1:length(tarr)
            R(:,it,:) = Rtemp(:,it,:) .* cos(tarr(it));
            Z(:,it,:) = Rtemp(:,it,:) .* sin(tarr(it));
        end
    case 3
        R = Rtemp;
        Z = Ztemp;
end
       

for iz=1:length(zarr)
 
 pcolor(R(:,:,iz),Z(:,:,iz),jac(:,:,iz)); shading interp; colorbar
 hold on

 axis equal
 title('|B|');
 xlabel('R');
 ylabel('Z');
end

% Output data

rzbdata{1} = R;
rzbdata{2} = Z;
rzbdata{3} = jac;
