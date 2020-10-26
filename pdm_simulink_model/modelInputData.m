%% PDM MODEL INPUT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Provides all the input data for the pdm model. Run this before running
% the Simulink model. The runTime variable may need to be modified at
% different frequecies to display data on the scope. The section at the
% end enables the raw pdm data stream to be save to a file for fpga
% simulation.
%
% Created By: G. Howell
% Created Date: 24/05/2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clearvars; close all; 

% general variables
fs = 48000;             % pcm sample rate

%%%%% SIGMA DELTA MODULATION (PDM SIGNAL) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pdmMulti = 64;          % sampling multiplier for the pdm signal
fsPdm = pdmMulti*fs;    % pdm signal sample rate

%%%%% INPUT SIGNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

amp = 0.999969482421875; % amplitude
freq = 1000;            % source frequency
fsAnalog = 10*fsPdm;    % sampling frequency to approximately model an 
                        % analog signal
                    
%%%%% CIC FILTER SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cicDecFact = pdmMulti;  % cic decimation factor
cicNormGain = 1/(2^(log2(cicDecFact)*4)); % cic normalisation gain

%%%%% CIC + HALF BAND FIR FILTERS SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cicFirDecFact = 8;      % cic decimation factor
cicFirNormGain = 1/(2^(log2(cicFirDecFact)*4)); % cic normalisation gain 

firDecFact = 2;         % fir decimation factor

%%%%% HP FILTER SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2nd order high pass filter to remove some of the low frequency noise

% hpf cutoff
hpfFc = 10;

% pole zero locations
[hpFlt_b,hpFlt_a] = butter(2,hpfFc/(fs/2),'high');
sosVec = [hpFlt_b,hpFlt_a];
                        
%%%%% RUNTIME SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% scopes
scopeDispTime = 1/freq * 2; % displays 2 periods of the input signal on the 
                            % time scopes
scopeOffset = 0;

% run time (related to min time for spectrum to update)
spectrumMin = 1966140/fsAnalog; % required time to update the spectrum window
runTime = spectrumMin;      % total runtime of simulation in seconds

%% PDM DATA SAVE
% save the mic pdm data to a file to be used in the fpga simulation

% fileID = fopen('simPdm.txt','w');
% fprintf(fileID,'%d\n',Sim_PDM_Output);
% fclose(fileID);