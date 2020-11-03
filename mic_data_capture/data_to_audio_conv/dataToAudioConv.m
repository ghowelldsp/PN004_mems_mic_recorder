%% DATA TO AUDIO CONVERSION
% simple script that converts pcm data in a .txt file to audio

clc; clearvars; close all;

% filenames
folder = './test_data/';
filenames = {'cic_m1'; 'cic_m2'; 'cicFir_m1'; 'cicFir_m2'; 'cicHp_m1'; ...
    'cicHp_m2'; 'cicFirHp_m1'; 'cicFirHp_m2'};
% filenames = {'cic_m1'; 'cic_m2'};

% variables
fs = 48000; % sample rate
gain = 1;  % 250

for ni=1:length(filenames)
    
    % import the audio data from the text files
    micData(:,ni) = gain*int16(textread([folder, filenames{ni},'.txt'],'%d'));
    
    % write data to .wav file
    audiowrite([folder, filenames{ni},'.wav'], micData(:,ni), fs)
end

wrongM1 = find(micData(:,1)~=1);