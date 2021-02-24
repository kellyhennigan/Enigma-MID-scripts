function [colors,lspec]=getTCPlotColLineSpec(stims)
% -------------------------------------------------------------------------
% usage: use this to define your desired plotting colors. This is useful so
% that lines for a given condition are always plotted in the color you
% choos
%
% INPUT:
%   stims - cell array of stim names (e.g., {'gain5','gain0'}
%
% OUTPUT:
%   colors - rgb values to use for plotting timecourses
%   lspec - cell array of line specs for plotting
%
% author: Kelly, kelhennigan@gmail.com, 12-Dec-2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if notDefined('stims')
    stims = {};
end

if ~iscell(stims)
    stims = {stims};
end

%%%%%% determine colors & line spec to return based on input labels %%%%%%%%%%%%%


colors = {};


for i=1:numel(stims)
    
    
    switch lower(stims{i})
        
        % add/edit as desired!!!
        
        case {'gain5','gain5-gain0'}
            
            colors{i}=  [37,52,148]./255; % dark blue
            lspec{i} = '-';
            
        case 'gain1'
            
            colors{i}=[5,112,176]./255; % blue
            lspec{i} = '-';
            
        case 'gain0'
            
            colors{i}= [116,169,207]./255; % light blue
            lspec{i} = '-';
            
        case {'loss5','loss5-loss0'}
            
            colors{i}=  [103,0,131]./255; % dark red
            lspec{i} = '-';
            
        case 'loss1'
            
            colors{i}=[203,24,29]./255; % red
            lspec{i} = '-';
            
        case 'loss0'
            
            colors{i}=[251,106,74]./255; % light red
            lspec{i} = '-';
            
        case {'gainwin','gainwin-gainmiss'}
            
            colors{i}=[33,113,181]./255; % blue
            lspec{i} = '-';
            
        case 'gainmiss'
            
            colors{i}=[33,113,181]./255; % blue
            lspec{i} = '--';
            
        case {'losswin','losswin-lossmiss','losshit'}
            
            colors{i}=[203,24,29]./255; % red
            lspec{i} = '-';
            
        case 'lossmiss'
            
            colors{i}=[203,24,29]./255; % red
            lspec{i} = '--';
            
    end
    
    
    %%
    
    
    %
    % for i=1:numel(stims)
    %
    %
    %     switch lower(stims{i})
    %
    %         % add/edit as desired!!!
    %
    %         case {'gain5','gain5-gain0'}
    %             colors(i,:)=  [250 32 161]./255; % pink
    %
    %         case 'gain1'
    %             colors(i,:)=[29 186 154]./255; % green
    %
    %         case 'gain0'
    %             colors(i,:)= [2 117 180]./255;     % blue
    %
    %         case {'loss5','loss5-loss0'}
    %             colors(i,:)=  [250 32 161]./255; % pink
    %
    %         case 'loss1'
    %             colors(i,:)=[29 186 154]./255; % green
    %
    %         case 'loss0'
    %             colors(i,:)=[2 117 180]./255;     % blue
    %
    %         case {'gainwin','gainwin-gainmiss'}
    %             colors(i,:)= [2 117 180]./255; % blue
    %
    %         case 'gainmiss'
    %             colors(i,:)=[ 253 44 20 ]./255; % red
    %
    %         case {'losswin','losswin-lossmiss','losshit'}
    %             colors(i,:)=[2 117 180]./255; % blue
    %
    %         case 'lossmiss'
    %              colors(i,:)= [ 253 44 20 ]./255; % red
    %
    %     end
    %
    %
    %
    
    
end

