function il = illuminantCreate(ilName, wave, varargin)
% Create an ISETCam illuminant (light source) structure.  
%
% Synopsis:
%   illuminantCreate(ilName, wave, varargin)
%
% Brief description:
%   The illuminant structure includes information about the SPD of the
%   illuminant and potentially about its spatial structure, as well.
%
% The illuminant data are stored in units of [photons/(sr m^2 nm)]
%
% Inputs
%   ilName    - Illuminant name (see below).  default is 'd65'
%   wave      - List of wavelengths.  Default is 400:10:700;
%   colorTemp - Required when ilName is blackbody (deg K)
%   luminance - Required when ilName is blackbody (cd/m2)
%
% Returns
%   il - An illuminant structure
%
% Illuminant names we can interpret here are:
%
%    blackbody                   - Choice of blackbody
%    d65, d50                    - Daylight illuminants
%    tungsten, fluorescent       - Indoor illuminants
%    555 nm                      - Monochromatic
%    equal energy, equal photons - Broad band for physics
%    illuminant c                - A CIE Standard
%
% See examples:
%  ieExamplesPrint('illuminantCreate');
%
% See also:  
%  illuminantSet/Get, s_sceneIlluminant, s_sceneIlluminantSpace,
%  illuminantRead
%

% Examples:
%{
   il = illuminantCreate('d65');
%}
%{
  wave = 400:10:700; cTemp = 3500; luminance = 100; 
  il = illuminantCreate('blackbody',wave, cTemp,luminance)
%}
%{
  wave = 400:5:700; cTemp = 5500; luminance = 10; 
  il = illuminantCreate('blackbody',wave,cTemp,luminance)
%}
%{
  wave = 400:10:700; 
  il = illuminantCreate('illuminant c',wave);
  plotRadiance(wave,illuminantGet(il,'photons'));
%}

%% Initialize parameters
if ieNotDefined('ilName'), ilName = 'd65'; end
if ieNotDefined('wave'), wave = 400:10:700; end

il.name = ilName;
il.type = 'illuminant';

%% There is no default
% The absence of a default could be a problem.

switch ieParamFormat(ilName)
    
    case {'d65','d50','tungsten','fluorescent','555nm','equalenergy','illuminantc','equalphotons'}
        % illuminantCreate('d65',luminance)
        illP.name = ilName;
        illP.luminance = 100;
        illP.spectrum.wave = wave;
        if ~isempty(varargin), illP.luminance = varargin{1}; end
        
        iEnergy = illuminantRead(illP);		    % [W/(sr m^2 nm)]
        iPhotons = Energy2Quanta(wave,iEnergy); % Check this step
        il = illuminantSet(il,'name',illP.name);

    case 'blackbody'
        % illuminantCreate('blackbody',5000,luminance);
        illP.name = 'blackbody';
        illP.temperature = 5000;
        illP.luminance   = 100;
        illP.spectrum.wave = wave;
        
        if ~isempty(varargin),   illP.temperature = varargin{1};  end
        if length(varargin) > 1, illP.luminance = varargin{2}; end
        
        iEnergy = illuminantRead(illP);		    % [W/(sr m^2 nm)]
        iPhotons = Energy2Quanta(wave,iEnergy); % Check this step
        
        il = illuminantSet(il,'name',sprintf('blackbody-%.0f',illP.temperature));
        
    otherwise
        error('unknown illuminant type %s\n',ilName);
end

%% Set the wavelength and photons and return

il = illuminantSet(il,'photons',iPhotons);  % [photons/(s sr m^2 nm)]
il = illuminantSet(il,'wave',wave);  % nm

end
