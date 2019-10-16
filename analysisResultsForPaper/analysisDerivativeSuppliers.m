% This script compares the derivative suppliers: AD-Recorder, AD-ADOL-C, and FD.
%
% Author: Antoine Falisse
% Date: 10/9/2019
%
clear all
close all
clc
%
% Threshold used to discriminate between optimal solutions. We exclude the
% solution from an initial guess if it is larger than 
% threshold*(lowest solution across guesses).
threshold = 1.01;

%% Settings
% Select trials
% 1:3 => QR-guess (AD-Recorder, AD-ADOL-C, FD)
% 4:6 => DI-guess-walking (AD-Recorder, AD-ADOL-C, FD)
% 7:9 => DI-guess-running / DIm (AD-Recorder, AD-ADOL-C, FD)
ww_2D  = [1,4,7,2,5,8,3,6,9];
ww_3D  = [1,4,7,2,5,8,3,6,9];
ww_pend = 2:10;
% Load pre-defined settings
pathmain = pwd;
[pathMainRepo,~,~] = fileparts(pathmain);
pathRepo_2D = [pathMainRepo,'\predictiveSimulations_2D\'];
pathSettings_2D = [pathRepo_2D,'Settings'];
addpath(genpath(pathSettings_2D));
pathRepo_3D = [pathMainRepo,'\trackingSimulations_3D\'];
pathSettings_3D = [pathRepo_3D,'Settings'];
addpath(genpath(pathSettings_3D));
pathResults_pend = [pathMainRepo,'\pendulumSimulations\Results\'];
% Fixed settings
subject = 'subject1';
body_mass = 62;
body_weight = 62*9.81;
% Colors
color_all(1,:) = [253,174,97]/255;     % Yellow
color_all(2,:) = [171,221,164]/255;    % Red
color_all(4,:) = [60,186,84]/255;      % Green
color_all(3,:) = [0,0,0];              % Black
color_all(5,:) = [72,133,237]/255;     % Blue

%% Load results: predSim 2D
% Select setup 
setup.ocp = 'PredSim_2D'; 
settings_2D
% Pre-allocation structures
Qs_opt_2D              = struct('m',[]);
Qdots_opt_2D           = struct('m',[]);
Acts_opt_2D            = struct('m',[]);
GRFs_opt_2D            = struct('m',[]);
Ts_opt_2D              = struct('m',[]);
Stats_2D               = struct('m',[]);
% Loop over cases
for k = 1:length(ww_2D)
    data_2D;
end

%% Load results: trackSim 3D
% Select setup 
setup.ocp = 'TrackSim_3D'; 
settings_3D
% Pre-allocation structures
Qs_opt_3D              = struct('m',[]);
Qdots_opt_3D           = struct('m',[]);
Acts_opt_3D            = struct('m',[]);
GRFs_opt_3D            = struct('m',[]);
Ts_opt_3D              = struct('m',[]);
Stats_3D               = struct('m',[]);
% Loop over cases
for k = 1:length(ww_3D)
    data_3D;
end

%% Extract Results predSim 2D
t_proc_2D = zeros(length(ww_2D),5);
n_iter_2D = zeros(length(ww_2D),1);
fail_2D = 0;
obj_2D.all = zeros(length(ww_2D),1);
for k = 1:length(ww_2D)
    obj_2D.all(k) = Stats_2D(ww_2D(k)).m.iterations.obj(end);
    if Stats_2D(ww_2D(k)).m.success
        t_proc_2D(k,1)  = Stats_2D(ww_2D(k)).m.t_proc_solver - ...
            Stats_2D(ww_2D(k)).m.t_proc_nlp_f - ...
            Stats_2D(ww_2D(k)).m.t_proc_nlp_g - ...
            Stats_2D(ww_2D(k)).m.t_proc_nlp_grad - ...
            Stats_2D(ww_2D(k)).m.t_proc_nlp_grad_f - ...
            Stats_2D(ww_2D(k)).m.t_proc_nlp_jac_g;
        t_proc_2D(k,2)  = Stats_2D(ww_2D(k)).m.t_proc_nlp_f;
        t_proc_2D(k,3)  = Stats_2D(ww_2D(k)).m.t_proc_nlp_g;
        t_proc_2D(k,4)  = Stats_2D(ww_2D(k)).m.t_proc_nlp_grad_f;
        t_proc_2D(k,5)  = Stats_2D(ww_2D(k)).m.t_proc_nlp_jac_g;
        n_iter_2D(k)    = Stats_2D(ww_2D(k)).m.iter_count;  
    else
        % If the trial did not converge, then we assign NaN
        t_proc_2D(k,:) = NaN;
        n_iter_2D(k) = NaN;
        obj_2D.all(k) = NaN;
        fail_2D = fail_2D + 1;
        disp(['PredSim 2D: trial ',num2str(ww_2D(k)),' did not converge']);
    end       
end
% Assess convergence: we extract the optimal cost.
obj_2D.Rec = obj_2D.all(1:3:end,1);
obj_2D.ADOLC = obj_2D.all(2:3:end,1);
obj_2D.FD = obj_2D.all(3:3:end,1);
% We discriminate between optimal solutions. We exclude the solution from an 
% initial guess if it is larger than threshold*(lowest solution across guesses).
min_obj_2D.Rec = min(obj_2D.Rec);
idx_obj_2D.Rec = obj_2D.Rec > (threshold*min_obj_2D.Rec);
min_obj_2D.ADOLC = min(obj_2D.ADOLC);
idx_obj_2D.ADOLC = obj_2D.ADOLC > (threshold*min_obj_2D.ADOLC);
min_obj_2D.FD = min(obj_2D.FD);
idx_obj_2D.FD = obj_2D.FD > (threshold*min_obj_2D.FD);
idx_obj_2D.all = [idx_obj_2D.Rec,idx_obj_2D.ADOLC,idx_obj_2D.FD];
% We compare the lowest optimal solutions across cases and issue a warning
% if they differ across cases
min_Rec_ADOLC = abs(min_obj_2D.Rec-min_obj_2D.ADOLC) < (1.02-threshold)*min(min_obj_2D.Rec,min_obj_2D.ADOLC);
min_Rec_FD = abs(min_obj_2D.Rec-min_obj_2D.FD) < (1.02-threshold)*min(min_obj_2D.Rec,min_obj_2D.FD);
if ~min_Rec_ADOLC
    disp('2D Pred Sim: Rec and ADOLC have different lowest optimal cost')
end
if ~min_Rec_FD
    disp('2D Pred Sim: Rec and FD have different lowest optimal cost')
end
% Average across AD-Recorder cases
t_proc_all.pred2D.Rec.all = t_proc_2D(1:3:end,:);
t_proc_all.pred2D.Rec.all(idx_obj_2D.Rec,:) = NaN;
t_proc_all.pred2D.Rec.all(:,end+1) = sum(t_proc_all.pred2D.Rec.all,2);
t_proc_all.pred2D.Rec.mean = nanmean(t_proc_all.pred2D.Rec.all,1);
t_proc_all.pred2D.Rec.std = nanstd(t_proc_all.pred2D.Rec.all,[],1);
n_iter_all.pred2D.Rec.all = n_iter_2D(1:3:end,:);
n_iter_all.pred2D.Rec.all(idx_obj_2D.Rec,:) = NaN;
n_iter_all.pred2D.Rec.mean = nanmean(n_iter_all.pred2D.Rec.all,1);
n_iter_all.pred2D.Rec.std = nanstd(n_iter_all.pred2D.Rec.all,[],1);
t_iter_all.pred2D.Rec.all = t_proc_all.pred2D.Rec.all(:,end)./n_iter_all.pred2D.Rec.all;
% Average across AD-ADOLC cases
t_proc_all.pred2D.ADOLC.all = t_proc_2D(2:3:end,:);
t_proc_all.pred2D.ADOLC.all(idx_obj_2D.ADOLC,:) = NaN;
t_proc_all.pred2D.ADOLC.all(:,end+1) = sum(t_proc_all.pred2D.ADOLC.all,2);
t_proc_all.pred2D.ADOLC.mean = nanmean(t_proc_all.pred2D.ADOLC.all,1);
t_proc_all.pred2D.ADOLC.std = nanstd(t_proc_all.pred2D.ADOLC.all,[],1);
n_iter_all.pred2D.ADOLC.all = n_iter_2D(2:3:end,:);
n_iter_all.pred2D.ADOLC.all(idx_obj_2D.ADOLC,:) = NaN;
n_iter_all.pred2D.ADOLC.mean = nanmean(n_iter_all.pred2D.ADOLC.all,1);
n_iter_all.pred2D.ADOLC.std = nanstd(n_iter_all.pred2D.ADOLC.all,[],1);
t_iter_all.pred2D.ADOLC.all = t_proc_all.pred2D.ADOLC.all(:,end)./n_iter_all.pred2D.ADOLC.all;
% Average across FD cases
t_proc_all.pred2D.FD.all = t_proc_2D(3:3:end,:);
t_proc_all.pred2D.FD.all(idx_obj_2D.FD,:) = NaN;
t_proc_all.pred2D.FD.all(:,end+1) = sum(t_proc_all.pred2D.FD.all,2);
t_proc_all.pred2D.FD.mean = nanmean(t_proc_all.pred2D.FD.all,1);
t_proc_all.pred2D.FD.std = nanstd(t_proc_all.pred2D.FD.all,[],1);
n_iter_all.pred2D.FD.all = n_iter_2D(3:3:end,:);
n_iter_all.pred2D.FD.all(idx_obj_2D.FD,:) = NaN;
n_iter_all.pred2D.FD.mean = nanmean(n_iter_all.pred2D.FD.all,1);
n_iter_all.pred2D.FD.std = nanstd(n_iter_all.pred2D.FD.all,[],1);
t_iter_all.pred2D.FD.all = t_proc_all.pred2D.FD.all(:,end)./n_iter_all.pred2D.FD.all;

%% Extract Results trackSim 3D
t_proc_3D = zeros(length(ww_3D),5);
n_iter_3D = zeros(length(ww_3D),1);
fail_3D = 0;
obj_3D.all = zeros(length(ww_3D),1);
for k = 1:length(ww_3D)
    obj_3D.all(k) = Stats_3D(ww_3D(k)).m.iterations.obj(end);
    if Stats_3D(ww_3D(k)).m.success
        t_proc_3D(k,1) = Stats_3D(ww_3D(k)).m.t_proc_solver - ...
            Stats_3D(ww_3D(k)).m.t_proc_nlp_f - ...
            Stats_3D(ww_3D(k)).m.t_proc_nlp_g - ...
            Stats_3D(ww_3D(k)).m.t_proc_nlp_grad - ...
            Stats_3D(ww_3D(k)).m.t_proc_nlp_grad_f - ...
            Stats_3D(ww_3D(k)).m.t_proc_nlp_jac_g;
        t_proc_3D(k,2) = Stats_3D(ww_3D(k)).m.t_proc_nlp_f;
        t_proc_3D(k,3) = Stats_3D(ww_3D(k)).m.t_proc_nlp_g;
        t_proc_3D(k,4) = Stats_3D(ww_3D(k)).m.t_proc_nlp_grad_f;
        t_proc_3D(k,5) = Stats_3D(ww_3D(k)).m.t_proc_nlp_jac_g;
        n_iter_3D(k)   = Stats_3D(ww_3D(k)).m.iter_count;    
    else
        t_proc_3D(k,:) = NaN;
        n_iter_3D(k) = NaN;
        obj_3D.all(k) = NaN;
        fail_3D = fail_3D + 1;
        disp(['TrackSim 3D: trial ',num2str(ww_3D(k)),' did not converge']);
    end    
end
% Assess convergence: we extract the optimal cost.
obj_3D.Rec = obj_3D.all(1:3:end,1);
obj_3D.ADOLC = obj_3D.all(2:3:end,1);
obj_3D.FD = obj_3D.all(3:3:end,1);
% We discriminate between optimal solutions. We exclude the solution from an 
% initial guess if it is larger than threshold*(lowest solution across guesses).
min_obj_3D.Rec = min(obj_3D.Rec);
idx_obj_3D.Rec = obj_3D.Rec > (threshold*min_obj_3D.Rec);
min_obj_3D.ADOLC = min(obj_3D.ADOLC);
idx_obj_3D.ADOLC = obj_3D.ADOLC > (threshold*min_obj_3D.ADOLC);
min_obj_3D.FD = min(obj_3D.FD);
idx_obj_3D.FD = obj_3D.FD > (threshold*min_obj_3D.FD);
idx_obj_3D.all = [idx_obj_3D.Rec,idx_obj_3D.ADOLC,idx_obj_3D.FD];
% We compare the lowest optimal solutions across cases and issue a warning
% if they differ across cases
min_Rec_ADOLC = abs(min_obj_3D.Rec-min_obj_3D.ADOLC) < (1.02-threshold)*min(min_obj_3D.Rec,min_obj_3D.ADOLC);
min_Rec_FD = abs(min_obj_3D.Rec-min_obj_3D.FD) < (1.02-threshold)*min(min_obj_3D.Rec,min_obj_3D.FD);
if ~min_Rec_ADOLC
    disp('3D Track Sim: Rec and ADOLC have different lowest optimal cost')
end
if ~min_Rec_FD
    disp('3D Track Sim: Rec and FD have different lowest optimal cost')
end
% Average across AD-Recorder cases
t_proc_all.track3D.Rec.all = t_proc_3D(1:3:end,:);
t_proc_all.track3D.Rec.all(idx_obj_3D.Rec,:) = NaN;
t_proc_all.track3D.Rec.all(:,end+1) = sum(t_proc_all.track3D.Rec.all,2);
t_proc_all.track3D.Rec.mean = nanmean(t_proc_all.track3D.Rec.all,1);
t_proc_all.track3D.Rec.std = nanstd(t_proc_all.track3D.Rec.all,[],1);
n_iter_all.track3D.Rec.all = n_iter_3D(1:3:end,:);
n_iter_all.track3D.Rec.all(idx_obj_3D.Rec,:) = NaN;
n_iter_all.track3D.Rec.mean = nanmean(n_iter_all.track3D.Rec.all,1);
n_iter_all.track3D.Rec.std = nanstd(n_iter_all.track3D.Rec.all,[],1);
t_iter_all.track3D.Rec.all = t_proc_all.track3D.Rec.all(:,end)./n_iter_all.track3D.Rec.all;
% Average across AD-ADOLC cases
t_proc_all.track3D.ADOLC.all = t_proc_3D(2:3:end,:);
t_proc_all.track3D.ADOLC.all(idx_obj_3D.ADOLC,:) = NaN;
t_proc_all.track3D.ADOLC.all(:,end+1) = sum(t_proc_all.track3D.ADOLC.all,2);
t_proc_all.track3D.ADOLC.mean = nanmean(t_proc_all.track3D.ADOLC.all,1);
t_proc_all.track3D.ADOLC.std = nanstd(t_proc_all.track3D.ADOLC.all,[],1);
n_iter_all.track3D.ADOLC.all = n_iter_3D(2:3:end,:);
n_iter_all.track3D.ADOLC.all(idx_obj_3D.ADOLC,:) = NaN;
n_iter_all.track3D.ADOLC.mean = nanmean(n_iter_all.track3D.ADOLC.all,1);
n_iter_all.track3D.ADOLC.std = nanstd(n_iter_all.track3D.ADOLC.all,[],1);
t_iter_all.track3D.ADOLC.all = t_proc_all.track3D.ADOLC.all(:,end)./n_iter_all.track3D.ADOLC.all;
% Average across FD cases
t_proc_all.track3D.FD.all = t_proc_3D(3:3:end,:);
t_proc_all.track3D.FD.all(idx_obj_3D.FD,:) = NaN;
t_proc_all.track3D.FD.all(:,end+1) = sum(t_proc_all.track3D.FD.all,2);
t_proc_all.track3D.FD.mean = nanmean(t_proc_all.track3D.FD.all,1);
t_proc_all.track3D.FD.std = nanstd(t_proc_all.track3D.FD.all,[],1);
n_iter_all.track3D.FD.all = n_iter_3D(3:3:end,:);
n_iter_all.track3D.FD.all(idx_obj_3D.FD,:) = NaN;
n_iter_all.track3D.FD.mean = nanmean(n_iter_all.track3D.FD.all,1);
n_iter_all.track3D.FD.std = nanstd(n_iter_all.track3D.FD.all,[],1);
t_iter_all.track3D.FD.all = t_proc_all.track3D.FD.all(:,end)./n_iter_all.track3D.FD.all;

%% Extract Results Pendulums
for i = 2:10
    % Add results from AD
    load([pathResults_pend,'\Pendulum_',num2str(i),'dofs\solution_AD'],...
        'solution');
    PendulumResultsAll.(['pendulum_',num2str(i),'dofs']).AD = solution;
    % Add results from FD
    load([pathResults_pend,'\Pendulum_',num2str(i),'dofs\solution_FD_F'],...
        'solution');
    PendulumResultsAll.(['pendulum_',num2str(i),'dofs']).FD = solution;
end
count = 1;
Options.solver='mumps'; dim4=1;
Options.Hessian='approx'; dim3=2;
tol_pend = 2;
ders = {'AD','FD'};
types={'Recorder','ADOLC'};
NIG = 10;
NCases_pend = length(ww_pend)*(length(ders)+1)*NIG;
t_proc_pend = zeros(NCases_pend,5);
n_iter_pend = zeros(NCases_pend,1);
obj_pend.all = zeros(NCases_pend,1);
fail_pend = 0;
for k = 2:length(ww_pend)+1 % loop over pendulum cases (eg 2dof)
    for der=ders % loop over derivative type (AD or FD)
        solution = PendulumResultsAll.(['pendulum_',num2str(k),'dofs']).(der{:});
        if strcmp(der{:},'AD')
            for type=types % if AD loop over AD-tool (Recorder or ADOL-C)
                if strcmp(type,'Recorder')
                    dim5=1;
                elseif strcmp(type,'ADOLC')
                    dim5=2;
                end
                for i_IG=1:NIG % loop over initial guesses            
                    stats_temp = solution(i_IG,tol_pend,dim3,dim4,dim5).stats;          
                    obj_pend.all(count) = stats_temp.iterations.obj(end);
                    if stats_temp.success
                        t_proc_pend(count,1) = stats_temp.t_proc_solver - ...
                            stats_temp.t_proc_nlp_f - ...
                            stats_temp.t_proc_nlp_g - ...
                            stats_temp.t_proc_nlp_grad - ...
                            stats_temp.t_proc_nlp_grad_f - ...
                            stats_temp.t_proc_nlp_jac_g;
                        t_proc_pend(count,2) = stats_temp.t_proc_nlp_f;
                        t_proc_pend(count,3) = stats_temp.t_proc_nlp_g;
                        t_proc_pend(count,4) = stats_temp.t_proc_nlp_grad_f;
                        t_proc_pend(count,5) = stats_temp.t_proc_nlp_jac_g;
                        n_iter_pend(count)   = stats_temp.iter_count;    
                    else
                        t_proc_pend(count,:) = NaN;
                        n_iter_pend(count) = NaN;
                        obj_pend.all(count) = NaN;
                        fail_pend = fail_pend + 1;
                        disp(['Pendulum: trial (AD) ',num2str(count),' did not converge']);
                    end                          
                    count = count + 1;
                end
            end
        elseif strcmp(der{:},'FD')
            dim5=1; % Recorder by default with FD
            for i_IG=1:NIG % loop over initial guesses              
                stats_temp = solution(i_IG,tol_pend,dim3,dim4,dim5).stats;          
                obj_pend.all(count) = stats_temp.iterations.obj(end);
                if stats_temp.success
                    t_proc_pend(count,1) = stats_temp.t_proc_solver - ...
                        stats_temp.t_proc_nlp_f - ...
                        stats_temp.t_proc_nlp_g - ...
                        stats_temp.t_proc_nlp_grad - ...
                        stats_temp.t_proc_nlp_grad_f - ...
                        stats_temp.t_proc_nlp_jac_g;
                    t_proc_pend(count,2) = stats_temp.t_proc_nlp_f;
                    t_proc_pend(count,3) = stats_temp.t_proc_nlp_g;
                    t_proc_pend(count,4) = stats_temp.t_proc_nlp_grad_f;
                    t_proc_pend(count,5) = stats_temp.t_proc_nlp_jac_g;
                    n_iter_pend(count)   = stats_temp.iter_count;    
                else
                    t_proc_pend(count,:) = NaN;
                    n_iter_pend(count) = NaN;
                    obj_pend.all(count) = NaN;
                    fail_pend = fail_pend + 1;
                    disp(['Pendulum: trial (FD) ',num2str(count),' did not converge']);
                end                          
                count = count + 1;
            end
        end
    end
end

% Assess convergence: we extract the optimal cost.
for k = 2:length(ww_pend)+1    
    obj_pend.(['pendulum',num2str(k),'dof']).Rec = obj_pend.all((k-2)*(3*NIG)+1:(k-2)*(3*NIG)+NIG,1);
    obj_pend.(['pendulum',num2str(k),'dof']).ADOLC = obj_pend.all((k-2)*(3*NIG)+1+NIG:(k-2)*(3*NIG)+2*NIG,1);
    obj_pend.(['pendulum',num2str(k),'dof']).FD = obj_pend.all((k-2)*(3*NIG)+1+2*NIG:(k-2)*(3*NIG)+3*NIG,1);
    % We discriminate between optimal solutions. We exclude the solution from an 
    % initial guess if it is larger than threshold*(lowest solution across guesses).
    min_obj_pend.Rec = min(obj_pend.(['pendulum',num2str(k),'dof']).Rec);
    idx_obj_pend.(['pendulum',num2str(k),'dof']).Rec = obj_pend.(['pendulum',num2str(k),'dof']).Rec > (threshold*min_obj_pend.Rec);
    min_obj_pend.ADOLC = min(obj_pend.(['pendulum',num2str(k),'dof']).ADOLC);
    idx_obj_pend.(['pendulum',num2str(k),'dof']).ADOLC = obj_pend.(['pendulum',num2str(k),'dof']).ADOLC > (threshold*min_obj_pend.ADOLC);
    min_obj_pend.FD = min(obj_pend.(['pendulum',num2str(k),'dof']).FD);
    idx_obj_pend.(['pendulum',num2str(k),'dof']).FD = obj_pend.(['pendulum',num2str(k),'dof']).FD > (threshold*min_obj_pend.FD);
    idx_obj_pend.(['pendulum',num2str(k),'dof']).all = [idx_obj_pend.(['pendulum',num2str(k),'dof']).Rec,...
        idx_obj_pend.(['pendulum',num2str(k),'dof']).ADOLC,idx_obj_pend.(['pendulum',num2str(k),'dof']).FD];
    % We compare the lowest optimal solutions across cases and issue a warning
    % if they differ across cases
    min_Rec_ADOLC = abs(min_obj_pend.Rec-min_obj_pend.ADOLC) < (1.02-threshold)*min(min_obj_pend.Rec,min_obj_pend.ADOLC);
    min_Rec_FD = abs(min_obj_pend.Rec-min_obj_pend.FD) < (1.02-threshold)*min(min_obj_pend.Rec,min_obj_pend.FD);
    if ~min_Rec_ADOLC
        disp(['Pendulum',num2str(k),'dof: Rec and ADOLC have different lowest optimal cost'])
    end
    if ~min_Rec_FD
        disp(['Pendulum',num2str(k),'dof: Rec and FD have different lowest optimal cost'])
    end
    % Average across AD-Recorder cases
    t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all = t_proc_pend((k-2)*(3*NIG)+1:(k-2)*(3*NIG)+NIG,:);
    t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all(idx_obj_pend.(['pendulum',num2str(k),'dof']).Rec,:) = NaN;
    t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all(:,end+1) = sum(t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all,2);
    t_proc_all.(['pendulum',num2str(k),'dof']).Rec.mean = nanmean(t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all,1);
    t_proc_all.(['pendulum',num2str(k),'dof']).Rec.std = nanstd(t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all,[],1);
    n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all = n_iter_pend((k-2)*(3*NIG)+1:(k-2)*(3*NIG)+NIG,:);
    n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all(idx_obj_pend.(['pendulum',num2str(k),'dof']).Rec,:) = NaN;
    n_iter_all.(['pendulum',num2str(k),'dof']).Rec.mean = nanmean(n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all,1);
    n_iter_all.(['pendulum',num2str(k),'dof']).Rec.std = nanstd(n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all,[],1);
    t_iter_all.(['pendulum',num2str(k),'dof']).Rec.all = t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all(:,end)./n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all;
    % Average across AD-ADOLC cases
    t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all = t_proc_pend((k-2)*(3*NIG)+1+NIG:(k-2)*(3*NIG)+2*NIG,:);
    t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all(idx_obj_pend.(['pendulum',num2str(k),'dof']).ADOLC,:) = NaN;
    t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all(:,end+1) = sum(t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all,2);
    t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.mean = nanmean(t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all,1);
    t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.std = nanstd(t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all,[],1);
    n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all = n_iter_pend((k-2)*(3*NIG)+1+NIG:(k-2)*(3*NIG)+2*NIG,:);
    n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all(idx_obj_pend.(['pendulum',num2str(k),'dof']).ADOLC,:) = NaN;
    n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.mean = nanmean(n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all,1);
    n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.std = nanstd(n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all,[],1);
    t_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all = t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all(:,end)./n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all;
    % Average across FD cases
    t_proc_all.(['pendulum',num2str(k),'dof']).FD.all = t_proc_pend((k-2)*(3*NIG)+1+2*NIG:(k-2)*(3*NIG)+3*NIG,:);
    t_proc_all.(['pendulum',num2str(k),'dof']).FD.all(idx_obj_pend.(['pendulum',num2str(k),'dof']).FD,:) = NaN;
    t_proc_all.(['pendulum',num2str(k),'dof']).FD.all(:,end+1) = sum(t_proc_all.(['pendulum',num2str(k),'dof']).FD.all,2);
    t_proc_all.(['pendulum',num2str(k),'dof']).FD.mean = nanmean(t_proc_all.(['pendulum',num2str(k),'dof']).FD.all,1);
    t_proc_all.(['pendulum',num2str(k),'dof']).FD.std = nanstd(t_proc_all.(['pendulum',num2str(k),'dof']).FD.all,[],1);
    n_iter_all.(['pendulum',num2str(k),'dof']).FD.all = n_iter_pend((k-2)*(3*NIG)+1+2*NIG:(k-2)*(3*NIG)+3*NIG,:);
    n_iter_all.(['pendulum',num2str(k),'dof']).FD.all(idx_obj_pend.(['pendulum',num2str(k),'dof']).FD,:) = NaN;
    n_iter_all.(['pendulum',num2str(k),'dof']).FD.mean = nanmean(n_iter_all.(['pendulum',num2str(k),'dof']).FD.all,1);
    n_iter_all.(['pendulum',num2str(k),'dof']).FD.std = nanstd(n_iter_all.(['pendulum',num2str(k),'dof']).FD.all,[],1);
    t_iter_all.(['pendulum',num2str(k),'dof']).FD.all = t_proc_all.(['pendulum',num2str(k),'dof']).FD.all(:,end)./n_iter_all.(['pendulum',num2str(k),'dof']).FD.all;
end                            

%% Differences in CPU time between cases
% Combine results from PredSim 2D and TrackSim 3D and Pendulums
t_proc_all.pred2D_3D_pend.Rec.all = [t_proc_all.pred2D.Rec.all;t_proc_all.track3D.Rec.all];
t_proc_all.pred2D_3D_pend.ADOLC.all = [t_proc_all.pred2D.ADOLC.all;t_proc_all.track3D.ADOLC.all];
t_proc_all.pred2D_3D_pend.FD.all = [t_proc_all.pred2D.FD.all;t_proc_all.track3D.FD.all];
for k = 2:length(ww_pend)+1 
    t_proc_all.pred2D_3D_pend.Rec.all = [t_proc_all.pred2D_3D_pend.Rec.all;t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all];
    t_proc_all.pred2D_3D_pend.ADOLC.all = [t_proc_all.pred2D_3D_pend.ADOLC.all;t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all];
    t_proc_all.pred2D_3D_pend.FD.all = [t_proc_all.pred2D_3D_pend.FD.all;t_proc_all.(['pendulum',num2str(k),'dof']).FD.all];
end
% Calculate ratios between ADOL-C and Recorder
% All: PredSim 2D, TrackSim 3D, and Pendulums
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all = t_proc_all.pred2D_3D_pend.ADOLC.all./t_proc_all.pred2D_3D_pend.Rec.all;
CPU_ratio.ADOLC_rec.pred2D_3D_pend.mean = nanmean(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all,1);
CPU_ratio.ADOLC_rec.pred2D_3D_pend.std = nanstd(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all,[],1);
% PredSim 2D
CPU_ratio.ADOLC_rec.pred2D.all = t_proc_all.pred2D.ADOLC.all./t_proc_all.pred2D.Rec.all;
CPU_ratio.ADOLC_rec.pred2D.mean = nanmean(CPU_ratio.ADOLC_rec.pred2D.all,1);
CPU_ratio.ADOLC_rec.pred2D.std = nanstd(CPU_ratio.ADOLC_rec.pred2D.all,[],1);
% TrackSim 3D
CPU_ratio.ADOLC_rec.track3D.all = t_proc_all.track3D.ADOLC.all./t_proc_all.track3D.Rec.all;
CPU_ratio.ADOLC_rec.track3D.mean = nanmean(CPU_ratio.ADOLC_rec.track3D.all,1);
CPU_ratio.ADOLC_rec.track3D.std = nanstd(CPU_ratio.ADOLC_rec.track3D.all,[],1);
% Pendulums
for k = 2:length(ww_pend)+1
    CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all = t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all./t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all;
    CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean = nanmean(CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,1);
    CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std = nanstd(CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,[],1);
    CPU_ratio.ADOLC_rec.pendulum_all.mean(k-1) = CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean(end);
    CPU_ratio.ADOLC_rec.pendulum_all.std(k-1) = CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std(end);
end
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean = [CPU_ratio.ADOLC_rec.pendulum_all.mean,CPU_ratio.ADOLC_rec.pred2D.mean(end),CPU_ratio.ADOLC_rec.track3D.mean(end)];
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_std = [CPU_ratio.ADOLC_rec.pendulum_all.std,CPU_ratio.ADOLC_rec.pred2D.std(end),CPU_ratio.ADOLC_rec.track3D.std(end)];
% Numbers for paper
[~,b] = min(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean);
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean_min = round(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean(b),1);
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_std_min = round(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_std(b),1);
[~,b] = max(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean);
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean_max = round(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_mean(b),1);
CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_std_max = round(CPU_ratio.ADOLC_rec.pred2D_3D_pend.all_std(b),1);
% Calculate ratios between FD and Recorder
% All: PredSim 2D, TrackSim 3D, and Pendulums
CPU_ratio.FD_rec.pred2D_3D_pend.all = t_proc_all.pred2D_3D_pend.FD.all./t_proc_all.pred2D_3D_pend.Rec.all;
CPU_ratio.FD_rec.pred2D_3D_pend.mean = nanmean(CPU_ratio.FD_rec.pred2D_3D_pend.all,1);
CPU_ratio.FD_rec.pred2D_3D_pend.std = nanstd(CPU_ratio.FD_rec.pred2D_3D_pend.all,[],1);
% PredSim 2D
CPU_ratio.FD_rec.pred2D.all = t_proc_all.pred2D.FD.all./t_proc_all.pred2D.Rec.all;
CPU_ratio.FD_rec.pred2D.mean = nanmean(CPU_ratio.FD_rec.pred2D.all,1);
CPU_ratio.FD_rec.pred2D.std = nanstd(CPU_ratio.FD_rec.pred2D.all,[],1);
% TrackSim 3D
CPU_ratio.FD_rec.track3D.all = t_proc_all.track3D.FD.all./t_proc_all.track3D.Rec.all;
CPU_ratio.FD_rec.track3D.mean = nanmean(CPU_ratio.FD_rec.track3D.all,1);
CPU_ratio.FD_rec.track3D.std = nanstd(CPU_ratio.FD_rec.track3D.all,[],1);
% Pendulums
for k = 2:length(ww_pend)+1
    CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all = t_proc_all.(['pendulum',num2str(k),'dof']).FD.all./t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all;
    CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean = nanmean(CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all,1);
    CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std = nanstd(CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all,[],1);
    CPU_ratio.FD_rec.pendulum_all.mean(k-1) = CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean(end);
    CPU_ratio.FD_rec.pendulum_all.std(k-1) = CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std(end);
end
CPU_ratio.FD_rec.pred2D_3D_pend.all_mean = [CPU_ratio.FD_rec.pendulum_all.mean,CPU_ratio.FD_rec.pred2D.mean(end),CPU_ratio.FD_rec.track3D.mean(end)];
CPU_ratio.FD_rec.pred2D_3D_pend.all_std = [CPU_ratio.FD_rec.pendulum_all.std,CPU_ratio.FD_rec.pred2D.std(end),CPU_ratio.FD_rec.track3D.std(end)];
% Numbers for paper
[~,b] = min(CPU_ratio.FD_rec.pred2D_3D_pend.all_mean);
CPU_ratio.FD_rec.pred2D_3D_pend.all_mean_min = round(CPU_ratio.FD_rec.pred2D_3D_pend.all_mean(b),1);
CPU_ratio.FD_rec.pred2D_3D_pend.all_std_min = round(CPU_ratio.FD_rec.pred2D_3D_pend.all_std(b),1);
[~,b] = max(CPU_ratio.FD_rec.pred2D_3D_pend.all_mean);
CPU_ratio.FD_rec.pred2D_3D_pend.all_mean_max = round(CPU_ratio.FD_rec.pred2D_3D_pend.all_mean(b),1);
CPU_ratio.FD_rec.pred2D_3D_pend.all_std_max = round(CPU_ratio.FD_rec.pred2D_3D_pend.all_std(b),1);
% Calculate differences between ADOL-C and Recorder
CPU_diff.ADOLC_rec.pred2D_3D_pend.all = t_proc_all.pred2D_3D_pend.ADOLC.all-t_proc_all.pred2D_3D_pend.Rec.all;
CPU_diff.ADOLC_rec.pred2D.all = t_proc_all.pred2D.ADOLC.all-t_proc_all.pred2D.Rec.all;
CPU_diff.ADOLC_rec.track3D.all = t_proc_all.track3D.ADOLC.all-t_proc_all.track3D.Rec.all;
for k = 2:length(ww_pend)+1
    CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).all = t_proc_all.(['pendulum',num2str(k),'dof']).ADOLC.all-t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all;
end
% Calculate differences between FD and Recorder
CPU_diff.FD_rec.pred2D_3D_pend.all = t_proc_all.pred2D_3D_pend.FD.all-t_proc_all.pred2D_3D_pend.Rec.all;
CPU_diff.FD_rec.pred2D.all = t_proc_all.pred2D.FD.all-t_proc_all.pred2D.Rec.all;
CPU_diff.FD_rec.track3D.all = t_proc_all.track3D.FD.all-t_proc_all.track3D.Rec.all;
for k = 2:length(ww_pend)+1
    CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).all = t_proc_all.(['pendulum',num2str(k),'dof']).FD.all-t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all;
end
% Calculate percentage contribution to overall difference between ADOL-C and Recorder
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all = CPU_diff.ADOLC_rec.pred2D_3D_pend.all(:,1:end-1)./repmat(CPU_diff.ADOLC_rec.pred2D_3D_pend.all(:,end),1,size(CPU_diff.ADOLC_rec.pred2D_3D_pend.all,2)-1).*100;
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.mean = nanmean(CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all,1);
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.std = nanstd(CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all,[],1);
CPU_diff.ADOLC_rec.pred2D.per.all = CPU_diff.ADOLC_rec.pred2D.all(:,1:end-1)./repmat(CPU_diff.ADOLC_rec.pred2D.all(:,end),1,size(CPU_diff.ADOLC_rec.pred2D.all,2)-1).*100;
CPU_diff.ADOLC_rec.pred2D.per.mean = nanmean(CPU_diff.ADOLC_rec.pred2D.per.all,1);
CPU_diff.ADOLC_rec.pred2D.per.std = nanstd(CPU_diff.ADOLC_rec.pred2D.per.all,[],1);
CPU_diff.ADOLC_rec.track3D.per.all = CPU_diff.ADOLC_rec.track3D.all(:,1:end-1)./repmat(CPU_diff.ADOLC_rec.track3D.all(:,end),1,size(CPU_diff.ADOLC_rec.track3D.all,2)-1).*100;
CPU_diff.ADOLC_rec.track3D.per.mean = nanmean(CPU_diff.ADOLC_rec.track3D.per.all,1);
CPU_diff.ADOLC_rec.track3D.per.std = nanstd(CPU_diff.ADOLC_rec.track3D.per.all,[],1);
for k = 2:length(ww_pend)+1
    CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.all = CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).all(:,1:end-1)./repmat(CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).all(:,end),1,size(CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,2)-1).*100;
    CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.mean = mean(CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.all,1);
    CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.std = std(CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.all,[],1); 
    % nlp_jac_g
    CPU_diff.ADOLC_rec.pendulum_all.per.mean_jac_g(k-1) = CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.mean(end);
    CPU_diff.ADOLC_rec.pendulum_all.per.std_jac_g(k-1) = CPU_diff.ADOLC_rec.(['pendulum',num2str(k),'dof']).per.std(end);    
end
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all_mean_jac_g = [CPU_diff.ADOLC_rec.pendulum_all.per.mean_jac_g,CPU_diff.ADOLC_rec.pred2D.per.mean(end),CPU_diff.ADOLC_rec.track3D.per.mean(end)];
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all_std_jac_g = [CPU_diff.ADOLC_rec.pendulum_all.per.std_jac_g,CPU_diff.ADOLC_rec.pred2D.per.std(end),CPU_diff.ADOLC_rec.track3D.per.std(end)];
% Numbers for paper (mean of mean): I want to give the same weight to the
% different examples. Taking the mean over all trials would give more
% importance to the pendulum cases although in the end the average does
% not really change. The std (variability) should change.
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all_mean_mean_jac_g = round(mean(CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all_mean_jac_g));
CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all_mean_std_jac_g = round(std(CPU_diff.ADOLC_rec.pred2D_3D_pend.per.all_mean_jac_g));
% Calculate percentage contribution to overall difference between FD and Recorder
CPU_diff.FD_rec.pred2D_3D_pend.per.all = CPU_diff.FD_rec.pred2D_3D_pend.all(:,1:end-1)./repmat(CPU_diff.FD_rec.pred2D_3D_pend.all(:,end),1,size(CPU_diff.FD_rec.pred2D_3D_pend.all,2)-1).*100;
CPU_diff.FD_rec.pred2D_3D_pend.per.mean = nanmean(CPU_diff.FD_rec.pred2D_3D_pend.per.all,1);
CPU_diff.FD_rec.pred2D_3D_pend.per.std = nanstd(CPU_diff.FD_rec.pred2D_3D_pend.per.all,[],1);
CPU_diff.FD_rec.pred2D.per.all = CPU_diff.FD_rec.pred2D.all(:,1:end-1)./repmat(CPU_diff.FD_rec.pred2D.all(:,end),1,size(CPU_diff.FD_rec.pred2D.all,2)-1).*100;
CPU_diff.FD_rec.pred2D.per.mean = nanmean(CPU_diff.FD_rec.pred2D.per.all,1);
CPU_diff.FD_rec.pred2D.per.std = nanstd(CPU_diff.FD_rec.pred2D.per.all,[],1);
CPU_diff.FD_rec.track3D.per.all = CPU_diff.FD_rec.track3D.all(:,1:end-1)./repmat(CPU_diff.FD_rec.track3D.all(:,end),1,size(CPU_diff.FD_rec.track3D.all,2)-1).*100;
CPU_diff.FD_rec.track3D.per.mean = nanmean(CPU_diff.FD_rec.track3D.per.all,1);
CPU_diff.FD_rec.track3D.per.std = nanstd(CPU_diff.FD_rec.track3D.per.all,[],1);
for k = 2:length(ww_pend)+1
    CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.all = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).all(:,1:end-1)./repmat(CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).all(:,end),1,size(CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).all,2)-1).*100;
    CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.mean = mean(CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.all,1);
    CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.std = std(CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.all,[],1);
    % solver
    CPU_diff.FD_rec.pendulum_all.per.mean_solver(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.mean(1);
    CPU_diff.FD_rec.pendulum_all.per.std_solver(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.std(1); 
    % nlp_f
    CPU_diff.FD_rec.pendulum_all.per.mean_f(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.mean(2);
    CPU_diff.FD_rec.pendulum_all.per.std_f(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.std(2); 
    % nlp_g
    CPU_diff.FD_rec.pendulum_all.per.mean_g(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.mean(3);
    CPU_diff.FD_rec.pendulum_all.per.std_g(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.std(3); 
    % nlp_grad_f
    CPU_diff.FD_rec.pendulum_all.per.mean_grad_f(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.mean(end-1);
    CPU_diff.FD_rec.pendulum_all.per.std_grad_f(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.std(end-1); 
    % nlp_jac_g
    CPU_diff.FD_rec.pendulum_all.per.mean_jac_g(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.mean(end);
    CPU_diff.FD_rec.pendulum_all.per.std_jac_g(k-1) = CPU_diff.FD_rec.(['pendulum',num2str(k),'dof']).per.std(end);  
end

% nlp_grad_f
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_solver = [CPU_diff.FD_rec.pendulum_all.per.mean_solver,CPU_diff.FD_rec.pred2D.per.mean(1),CPU_diff.FD_rec.track3D.per.mean(1)];
CPU_diff.FD_rec.pred2D_3D_pend.per.all_std_solver = [CPU_diff.FD_rec.pendulum_all.per.std_solver,CPU_diff.FD_rec.pred2D.per.std(1),CPU_diff.FD_rec.track3D.per.std(1)];
% nlp_f
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_f = [CPU_diff.FD_rec.pendulum_all.per.mean_f,CPU_diff.FD_rec.pred2D.per.mean(2),CPU_diff.FD_rec.track3D.per.mean(2)];
CPU_diff.FD_rec.pred2D_3D_pend.per.all_std_f = [CPU_diff.FD_rec.pendulum_all.per.std_f,CPU_diff.FD_rec.pred2D.per.std(2),CPU_diff.FD_rec.track3D.per.std(2)];
% nlp_g
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_g = [CPU_diff.FD_rec.pendulum_all.per.mean_g,CPU_diff.FD_rec.pred2D.per.mean(3),CPU_diff.FD_rec.track3D.per.mean(3)];
CPU_diff.FD_rec.pred2D_3D_pend.per.all_std_g = [CPU_diff.FD_rec.pendulum_all.per.std_g,CPU_diff.FD_rec.pred2D.per.std(3),CPU_diff.FD_rec.track3D.per.std(3)];
% nlp_grad_f
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_grad_f = [CPU_diff.FD_rec.pendulum_all.per.mean_grad_f,CPU_diff.FD_rec.pred2D.per.mean(end-1),CPU_diff.FD_rec.track3D.per.mean(end-1)];
CPU_diff.FD_rec.pred2D_3D_pend.per.all_std_grad_f = [CPU_diff.FD_rec.pendulum_all.per.std_grad_f,CPU_diff.FD_rec.pred2D.per.std(end-1),CPU_diff.FD_rec.track3D.per.std(end-1)];
% nlp_jac_g
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_jac_g = [CPU_diff.FD_rec.pendulum_all.per.mean_jac_g,CPU_diff.FD_rec.pred2D.per.mean(end),CPU_diff.FD_rec.track3D.per.mean(end)];
CPU_diff.FD_rec.pred2D_3D_pend.per.all_std_jac_g = [CPU_diff.FD_rec.pendulum_all.per.std_jac_g,CPU_diff.FD_rec.pred2D.per.std(end),CPU_diff.FD_rec.track3D.per.std(end)];
% Numbers for paper (mean of mean): I want to give the same weight to the
% different examples. Taking the mean over all trials would give more
% importance to the pendulum cases although in the end the average does
% not really change. The std (variability) should change.
% nlp_solver
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_mean_solver = round(mean(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_solver));
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_std_solver = round(std(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_solver));
% nlp_f
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_mean_f = round(mean(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_f));
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_std_f = round(std(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_f));
% nlp_g
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_mean_g = round(mean(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_g));
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_std_g = round(std(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_g));
% nlp_grad_f
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_mean_grad_f = round(mean(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_grad_f));
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_std_grad_f = round(std(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_grad_f));
% nlp_jac_g
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_mean_jac_g = round(mean(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_jac_g));
CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_std_jac_g = round(std(CPU_diff.FD_rec.pred2D_3D_pend.per.all_mean_jac_g));

%% Differences in number of iterations between cases
% Combine results from PredSim 2D and TrackSim 3D and Pendulums
n_iter_all.pred2D_3D_pend.Rec.all = [n_iter_all.pred2D.Rec.all;n_iter_all.track3D.Rec.all];
n_iter_all.pred2D_3D_pend.ADOLC.all = [n_iter_all.pred2D.ADOLC.all;n_iter_all.track3D.ADOLC.all];
n_iter_all.pred2D_3D_pend.FD.all = [n_iter_all.pred2D.FD.all;n_iter_all.track3D.FD.all];
for k = 2:length(ww_pend)+1 
    n_iter_all.pred2D_3D_pend.Rec.all = [n_iter_all.pred2D_3D_pend.Rec.all;n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all];
    n_iter_all.pred2D_3D_pend.ADOLC.all = [n_iter_all.pred2D_3D_pend.ADOLC.all;n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all];
    n_iter_all.pred2D_3D_pend.FD.all = [n_iter_all.pred2D_3D_pend.FD.all;n_iter_all.(['pendulum',num2str(k),'dof']).FD.all];
end
% Calculate ratios between ADOL-C and Recorder
% All: PredSim 2D, TrackSim 3D, and Pendulums
iter_ratio.ADOLC_rec.pred2D_3D_pend.all = n_iter_all.pred2D_3D_pend.ADOLC.all./n_iter_all.pred2D_3D_pend.Rec.all;
iter_ratio.ADOLC_rec.pred2D_3D_pend.mean = nanmean(iter_ratio.ADOLC_rec.pred2D_3D_pend.all,1);
iter_ratio.ADOLC_rec.pred2D_3D_pend.std = nanstd(iter_ratio.ADOLC_rec.pred2D_3D_pend.all,[],1);
% PredSim 2D
iter_ratio.ADOLC_rec.pred2D.all = n_iter_all.pred2D.ADOLC.all./n_iter_all.pred2D.Rec.all;
iter_ratio.ADOLC_rec.pred2D.mean = nanmean(iter_ratio.ADOLC_rec.pred2D.all,1);
iter_ratio.ADOLC_rec.pred2D.std = nanstd(iter_ratio.ADOLC_rec.pred2D.all,[],1);
% TrackSim 3D
iter_ratio.ADOLC_rec.track3D.all = n_iter_all.track3D.ADOLC.all./n_iter_all.track3D.Rec.all;
iter_ratio.ADOLC_rec.track3D.mean = nanmean(iter_ratio.ADOLC_rec.track3D.all,1);
iter_ratio.ADOLC_rec.track3D.std = nanstd(iter_ratio.ADOLC_rec.track3D.all,[],1);
% Pendulums
for k = 2:length(ww_pend)+1
    iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all = n_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all./n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all;
    iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean = nanmean(iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,1);
    iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std = nanstd(iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,[],1);
    iter_ratio.ADOLC_rec.pendulum_all.mean(k-1) = iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean;
    iter_ratio.ADOLC_rec.pendulum_all.std(k-1) = iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std;    
end
iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean = [iter_ratio.ADOLC_rec.pendulum_all.mean,iter_ratio.ADOLC_rec.pred2D.mean,iter_ratio.ADOLC_rec.track3D.mean];
iter_ratio.ADOLC_rec.pred2D_3D_pend.all_std = [iter_ratio.ADOLC_rec.pendulum_all.std,iter_ratio.ADOLC_rec.pred2D.std,iter_ratio.ADOLC_rec.track3D.std];
% Numbers for paper (mean of mean): I want to give the same weight to the
% different examples. Taking the mean over all trials would give more
% importance to the pendulum cases although in the end the average does
% not really change. The std (variability) should change.
iter_ratio.ADOLC_rec.pred2D_3D_pend.mean_mean = mean(iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean);
iter_ratio.ADOLC_rec.pred2D_3D_pend.mean_std = std(iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean);
% Calculate ratios between FD and Recorder
% All: PredSim 2D, TrackSim 3D, and Pendulums
iter_ratio.FD_rec.pred2D_3D_pend.all = n_iter_all.pred2D_3D_pend.FD.all./n_iter_all.pred2D_3D_pend.Rec.all;
iter_ratio.FD_rec.pred2D_3D_pend.mean = nanmean(iter_ratio.FD_rec.pred2D_3D_pend.all,1);
iter_ratio.FD_rec.pred2D_3D_pend.std = nanstd(iter_ratio.FD_rec.pred2D_3D_pend.all,[],1);
% PredSim 2D
iter_ratio.FD_rec.pred2D.all = n_iter_all.pred2D.FD.all./n_iter_all.pred2D.Rec.all;
iter_ratio.FD_rec.pred2D.mean = nanmean(iter_ratio.FD_rec.pred2D.all,1);
iter_ratio.FD_rec.pred2D.std = nanstd(iter_ratio.FD_rec.pred2D.all,[],1);
% TrackSim 3D
iter_ratio.FD_rec.track3D.all = n_iter_all.track3D.FD.all./n_iter_all.track3D.Rec.all;
iter_ratio.FD_rec.track3D.mean = nanmean(iter_ratio.FD_rec.track3D.all,1);
iter_ratio.FD_rec.track3D.std = nanstd(iter_ratio.FD_rec.track3D.all,[],1);
% Pendulums
for k = 2:length(ww_pend)+1
    iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all = n_iter_all.(['pendulum',num2str(k),'dof']).FD.all./n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all;
    iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean = nanmean(iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all,1);
    iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std = nanstd(iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all,[],1);
    iter_ratio.FD_rec.pendulum_all.mean(k-1) = iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean;
    iter_ratio.FD_rec.pendulum_all.std(k-1) = iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std;    
end
iter_ratio.FD_rec.pred2D_3D_pend.all_mean = [iter_ratio.FD_rec.pendulum_all.mean,iter_ratio.FD_rec.pred2D.mean,iter_ratio.FD_rec.track3D.mean];
iter_ratio.FD_rec.pred2D_3D_pend.all_std = [iter_ratio.FD_rec.pendulum_all.std,iter_ratio.FD_rec.pred2D.std,iter_ratio.FD_rec.track3D.std];
% Numbers for paper (mean of mean): I want to give the same weight to the
% different examples. Taking the mean over all trials would give more
% importance to the pendulum cases although in the end the average does
% not really change. The std (variability) should change.
iter_ratio.FD_rec.pred2D_3D_pend.mean_mean = mean(iter_ratio.FD_rec.pred2D_3D_pend.all_mean);
iter_ratio.FD_rec.pred2D_3D_pend.mean_std = std(iter_ratio.FD_rec.pred2D_3D_pend.all_mean);

%% Differences in CPU time per iteration
% Combine results from PredSim 2D and TrackSim 3D and Pendulums
t_iter_all.pred2D_3D_pend.Rec.all = [t_iter_all.pred2D.Rec.all;t_iter_all.track3D.Rec.all];
t_iter_all.pred2D_3D_pend.ADOLC.all = [t_iter_all.pred2D.ADOLC.all;t_iter_all.track3D.ADOLC.all];
t_iter_all.pred2D_3D_pend.FD.all = [t_iter_all.pred2D.FD.all;t_iter_all.track3D.FD.all];
for k = 2:length(ww_pend)+1 
    t_iter_all.pred2D_3D_pend.Rec.all = [t_iter_all.pred2D_3D_pend.Rec.all;t_iter_all.(['pendulum',num2str(k),'dof']).Rec.all];
    t_iter_all.pred2D_3D_pend.ADOLC.all = [t_iter_all.pred2D_3D_pend.ADOLC.all;t_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all];
    t_iter_all.pred2D_3D_pend.FD.all = [t_iter_all.pred2D_3D_pend.FD.all;t_iter_all.(['pendulum',num2str(k),'dof']).FD.all];
end
% Calculate ratios between ADOL-C and Recorder
% All: PredSim 2D, TrackSim 3D, and Pendulums
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all = t_iter_all.pred2D_3D_pend.ADOLC.all./t_iter_all.pred2D_3D_pend.Rec.all;
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.mean = nanmean(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all,1);
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.std = nanstd(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all,[],1);
% PredSim 2D
t_iter_ratio.ADOLC_rec.pred2D.all = t_iter_all.pred2D.ADOLC.all./t_iter_all.pred2D.Rec.all;
t_iter_ratio.ADOLC_rec.pred2D.mean = nanmean(t_iter_ratio.ADOLC_rec.pred2D.all,1);
t_iter_ratio.ADOLC_rec.pred2D.std = nanstd(t_iter_ratio.ADOLC_rec.pred2D.all,[],1);
% TrackSim 3D
t_iter_ratio.ADOLC_rec.track3D.all = t_iter_all.track3D.ADOLC.all./t_iter_all.track3D.Rec.all;
t_iter_ratio.ADOLC_rec.track3D.mean = nanmean(t_iter_ratio.ADOLC_rec.track3D.all,1);
t_iter_ratio.ADOLC_rec.track3D.std = nanstd(t_iter_ratio.ADOLC_rec.track3D.all,[],1);
% Pendulums
for k = 2:length(ww_pend)+1
    t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all = t_iter_all.(['pendulum',num2str(k),'dof']).ADOLC.all./t_iter_all.(['pendulum',num2str(k),'dof']).Rec.all;
    t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean = nanmean(t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,1);
    t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std = nanstd(t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).all,[],1);
    t_iter_ratio.ADOLC_rec.pendulum_all.mean(k-1) = t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean(end);
    t_iter_ratio.ADOLC_rec.pendulum_all.std(k-1) = t_iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std(end);
end
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean = [t_iter_ratio.ADOLC_rec.pendulum_all.mean,t_iter_ratio.ADOLC_rec.pred2D.mean(end),t_iter_ratio.ADOLC_rec.track3D.mean(end)];
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_std = [t_iter_ratio.ADOLC_rec.pendulum_all.std,t_iter_ratio.ADOLC_rec.pred2D.std(end),t_iter_ratio.ADOLC_rec.track3D.std(end)];
% Numbers for paper
[~,b] = min(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean);
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean_min = round(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean(b),1);
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_std_min = round(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_std(b),1);
[~,b] = max(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean);
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean_max = round(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_mean(b),1);
t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_std_max = round(t_iter_ratio.ADOLC_rec.pred2D_3D_pend.all_std(b),1);
% Calculate ratios between FD and Recorder
% All: PredSim 2D, TrackSim 3D, and Pendulums
t_iter_ratio.FD_rec.pred2D_3D_pend.all = t_iter_all.pred2D_3D_pend.FD.all./t_iter_all.pred2D_3D_pend.Rec.all;
t_iter_ratio.FD_rec.pred2D_3D_pend.mean = nanmean(t_iter_ratio.FD_rec.pred2D_3D_pend.all,1);
t_iter_ratio.FD_rec.pred2D_3D_pend.std = nanstd(t_iter_ratio.FD_rec.pred2D_3D_pend.all,[],1);
% PredSim 2D
t_iter_ratio.FD_rec.pred2D.all = t_iter_all.pred2D.FD.all./t_iter_all.pred2D.Rec.all;
t_iter_ratio.FD_rec.pred2D.mean = nanmean(t_iter_ratio.FD_rec.pred2D.all,1);
t_iter_ratio.FD_rec.pred2D.std = nanstd(t_iter_ratio.FD_rec.pred2D.all,[],1);
% TrackSim 3D
t_iter_ratio.FD_rec.track3D.all = t_iter_all.track3D.FD.all./t_iter_all.track3D.Rec.all;
t_iter_ratio.FD_rec.track3D.mean = nanmean(t_iter_ratio.FD_rec.track3D.all,1);
t_iter_ratio.FD_rec.track3D.std = nanstd(t_iter_ratio.FD_rec.track3D.all,[],1);
% Pendulums
for k = 2:length(ww_pend)+1
    t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all = t_iter_all.(['pendulum',num2str(k),'dof']).FD.all./t_iter_all.(['pendulum',num2str(k),'dof']).Rec.all;
    t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean = nanmean(t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all,1);
    t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std = nanstd(t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).all,[],1);
    t_iter_ratio.FD_rec.pendulum_all.mean(k-1) = t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean(end);
    t_iter_ratio.FD_rec.pendulum_all.std(k-1) = t_iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std(end);
end
t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean = [t_iter_ratio.FD_rec.pendulum_all.mean,t_iter_ratio.FD_rec.pred2D.mean(end),t_iter_ratio.FD_rec.track3D.mean(end)];
t_iter_ratio.FD_rec.pred2D_3D_pend.all_std = [t_iter_ratio.FD_rec.pendulum_all.std,t_iter_ratio.FD_rec.pred2D.std(end),t_iter_ratio.FD_rec.track3D.std(end)];
% Numbers for paper
[~,b] = min(t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean);
t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean_min = round(t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean(b),1);
t_iter_ratio.FD_rec.pred2D_3D_pend.all_std_min = round(t_iter_ratio.FD_rec.pred2D_3D_pend.all_std(b),1);
[~,b] = max(t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean);
t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean_max = round(t_iter_ratio.FD_rec.pred2D_3D_pend.all_mean(b),1);
t_iter_ratio.FD_rec.pred2D_3D_pend.all_std_max = round(t_iter_ratio.FD_rec.pred2D_3D_pend.all_std(b),1);

%% Plots: 2 studied cases merged
label_fontsize  = 18;
sup_fontsize  = 24;
line_linewidth  = 3;
ylim_CPU = [0 30];
NumTicks_CPU = 4;
ylim_iter = [0 1.5];
NumTicks_iter = 4;

figure()
subplot(3,2,1)
CPU_ratio_4plots.ADOLC_rec_fd.mean = zeros(length(ww_pend),2);
CPU_ratio_4plots.ADOLC_rec_fd.std = zeros(length(ww_pend),2);
for k = 2:length(ww_pend)+1
    CPU_ratio_4plots.ADOLC_rec_fd.mean(k-1,2) = CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean(end);
    CPU_ratio_4plots.ADOLC_rec_fd.std(k-1,2) = CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std(end);
    CPU_ratio_4plots.ADOLC_rec_fd.mean(k-1,1) = CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean(end);
    CPU_ratio_4plots.ADOLC_rec_fd.std(k-1,1) = CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std(end);
end
CPU_ratio_4plots.ADOLC_rec_fd.mean(k,2) = CPU_ratio.ADOLC_rec.pred2D.mean(end);
CPU_ratio_4plots.ADOLC_rec_fd.mean(k+1,2) = CPU_ratio.ADOLC_rec.track3D.mean(end);
CPU_ratio_4plots.ADOLC_rec_fd.std(k,2) = CPU_ratio.ADOLC_rec.pred2D.std(end);
CPU_ratio_4plots.ADOLC_rec_fd.std(k+1,2) = CPU_ratio.ADOLC_rec.track3D.std(end);
CPU_ratio_4plots.ADOLC_rec_fd.mean(k,1) = CPU_ratio.FD_rec.pred2D.mean(end);
CPU_ratio_4plots.ADOLC_rec_fd.mean(k+1,1) = CPU_ratio.FD_rec.track3D.mean(end);
CPU_ratio_4plots.ADOLC_rec_fd.std(k,1) = CPU_ratio.FD_rec.pred2D.std(end);
CPU_ratio_4plots.ADOLC_rec_fd.std(k+1,1) = CPU_ratio.FD_rec.track3D.std(end);
h1 = barwitherr(CPU_ratio_4plots.ADOLC_rec_fd.std,CPU_ratio_4plots.ADOLC_rec_fd.mean);
set(h1(1),'FaceColor',color_all(1,:),'EdgeColor',color_all(1,:));
set(h1(2),'FaceColor',color_all(2,:),'EdgeColor',color_all(2,:));
hold on;
L = get(gca,'XLim');
plot([L(1) L(2)],[1 1],'k','linewidth',1);
set(gca,'Fontsize',label_fontsize);  
set(gca,'XTickLabel',{'','','','','','','','','','',''},'Fontsize',label_fontsize');
ylabel('CPU time','Fontsize',label_fontsize');
ylim([ylim_CPU(1) ylim_CPU(2)]);
L = get(gca,'YLim');
set(gca,'YTick',linspace(L(1),L(2),NumTicks_CPU));     
l = legend('FD / AD-Recorder','AD-ADOLC / AD-Recorder');
set(gca,'Fontsize',label_fontsize);  
set(l,'Fontsize',label_fontsize); 
set(l,'location','Northwest');
box off;
subplot(3,2,3)
iter_ratio_4plots.ADOLC_rec_fd.mean = zeros(length(ww_pend),2);
iter_ratio_4plots.ADOLC_rec_fd.std = zeros(length(ww_pend),2);
for k = 2:length(ww_pend)+1
    iter_ratio_4plots.ADOLC_rec_fd.mean(k-1,2) = iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean(end);
    iter_ratio_4plots.ADOLC_rec_fd.std(k-1,2) = iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std(end);
    iter_ratio_4plots.ADOLC_rec_fd.mean(k-1,1) = iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean(end);
    iter_ratio_4plots.ADOLC_rec_fd.std(k-1,1) = iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std(end);
end
iter_ratio_4plots.ADOLC_rec_fd.mean(k,2) = iter_ratio.ADOLC_rec.pred2D.mean(end);
iter_ratio_4plots.ADOLC_rec_fd.mean(k+1,2) = iter_ratio.ADOLC_rec.track3D.mean(end);
iter_ratio_4plots.ADOLC_rec_fd.std(k,2) = iter_ratio.ADOLC_rec.pred2D.std(end);
iter_ratio_4plots.ADOLC_rec_fd.std(k+1,2) = iter_ratio.ADOLC_rec.track3D.std(end);
iter_ratio_4plots.ADOLC_rec_fd.mean(k,1) = iter_ratio.FD_rec.pred2D.mean(end);
iter_ratio_4plots.ADOLC_rec_fd.mean(k+1,1) = iter_ratio.FD_rec.track3D.mean(end);
iter_ratio_4plots.ADOLC_rec_fd.std(k,1) = iter_ratio.FD_rec.pred2D.std(end);
iter_ratio_4plots.ADOLC_rec_fd.std(k+1,1) = iter_ratio.FD_rec.track3D.std(end);
h2 = barwitherr(iter_ratio_4plots.ADOLC_rec_fd.std,iter_ratio_4plots.ADOLC_rec_fd.mean);
set(h2(1),'FaceColor',color_all(1,:),'EdgeColor',color_all(1,:));
set(h2(2),'FaceColor',color_all(2,:),'EdgeColor',color_all(2,:));
hold on;
L = get(gca,'XLim');
plot([L(1) L(2)],[1 1],'k','linewidth',1);
set(gca,'Fontsize',label_fontsize);  
set(gca,'XTickLabel',{'','','','','','','','','','',''},'Fontsize',label_fontsize');
% set(gca,'XTickLabel',{'Pend. 2dofs','Pend. 3dofs','Pend. 4dofs','Pend. 5dofs','Pend. 6dofs',...
%     'Pend. 7dofs','Pend. 8dofs','Pend. 9dofs','Pend. 10dofs','2D Pred. sim.','3D Track. sim.'},'Fontsize',label_fontsize');
% xtickangle(45)
ylabel('Iterations','Fontsize',label_fontsize');
ylim([ylim_iter(1) ylim_iter(2)]);
L = get(gca,'YLim');
set(gca,'YTick',linspace(L(1),L(2),NumTicks_iter));    
% l = legend('AD-ADOLC / AD-Recorder','FD / AD-Recorder');
% set(gca,'Fontsize',label_fontsize);  
% set(l,'Fontsize',label_fontsize); 
% set(l,'location','Northwest');
box off;

% %% Plots: 2 studied cases separated
% figure()
% subplot(2,2,1)
% CPU_ratio_4plots.ADOLC_rec.mean = zeros(1,length(ww_pend));
% CPU_ratio_4plots.ADOLC_rec.std = zeros(1,length(ww_pend));
% for k = 2:length(ww_pend)+1
%     CPU_ratio_4plots.ADOLC_rec.mean(1,k-1) = CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean(end);
%     CPU_ratio_4plots.ADOLC_rec.std(1,k-1) = CPU_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std(end);
% end
% CPU_ratio_4plots.ADOLC_rec.mean(1,end+1) = CPU_ratio.ADOLC_rec.pred2D.mean(end);
% CPU_ratio_4plots.ADOLC_rec.mean(1,end+1) = CPU_ratio.ADOLC_rec.track3D.mean(end);
% CPU_ratio_4plots.ADOLC_rec.std(1,end+1) = CPU_ratio.ADOLC_rec.pred2D.std(end);
% CPU_ratio_4plots.ADOLC_rec.std(1,end+1) = CPU_ratio.ADOLC_rec.track3D.std(end);
% h1 = barwitherr(CPU_ratio_4plots.ADOLC_rec.std,CPU_ratio_4plots.ADOLC_rec.mean);
% set(gca,'Fontsize',label_fontsize);  
% set(gca,'XTickLabel',{'','','','','','','','','','',''},'Fontsize',label_fontsize');
% ylabel('CPU time','Fontsize',label_fontsize');
% ylim([0 25]);
% title('Ratio AD-ADOL-C over AD-Recorder','Fontsize',label_fontsize');
% box off;
% subplot(2,2,2)
% CPU_ratio_4plots.FD_rec.mean = zeros(1,length(ww_pend));
% CPU_ratio_4plots.FD_rec.std = zeros(1,length(ww_pend));
% for k = 2:length(ww_pend)+1
%     CPU_ratio_4plots.FD_rec.mean(1,k-1) = CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean(end);
%     CPU_ratio_4plots.FD_rec.std(1,k-1) = CPU_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std(end);
% end
% CPU_ratio_4plots.FD_rec.mean(1,end+1) = CPU_ratio.FD_rec.pred2D.mean(end);
% CPU_ratio_4plots.FD_rec.mean(1,end+1) = CPU_ratio.FD_rec.track3D.mean(end);
% CPU_ratio_4plots.FD_rec.std(1,end+1) = CPU_ratio.FD_rec.pred2D.std(end);
% CPU_ratio_4plots.FD_rec.std(1,end+1) = CPU_ratio.FD_rec.track3D.std(end);
% h2 = barwitherr(CPU_ratio_4plots.FD_rec.std,CPU_ratio_4plots.FD_rec.mean);
% set(gca,'Fontsize',label_fontsize);  
% set(gca,'XTickLabel',{'','','','','','','','','','',''},'Fontsize',label_fontsize');
% % ylabel('CPU time (FD/Recorder)','Fontsize',label_fontsize');
% ylim([0 25]);
% title('Ratio FD over AD-Recorder','Fontsize',label_fontsize');
% 
% box off;
% subplot(2,2,3)
% iter_ratio_4plots.ADOLC_rec.mean = zeros(1,length(ww_pend));
% iter_ratio_4plots.ADOLC_rec.std = zeros(1,length(ww_pend));
% for k = 2:length(ww_pend)+1
%     iter_ratio_4plots.ADOLC_rec.mean(1,k-1) = iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).mean(end);
%     iter_ratio_4plots.ADOLC_rec.std(1,k-1) = iter_ratio.ADOLC_rec.(['pendulum',num2str(k),'dof']).std(end);
% end
% iter_ratio_4plots.ADOLC_rec.mean(1,end+1) = iter_ratio.ADOLC_rec.pred2D.mean(end);
% iter_ratio_4plots.ADOLC_rec.mean(1,end+1) = iter_ratio.ADOLC_rec.track3D.mean(end);
% iter_ratio_4plots.ADOLC_rec.std(1,end+1) = iter_ratio.ADOLC_rec.pred2D.std(end);
% iter_ratio_4plots.ADOLC_rec.std(1,end+1) = iter_ratio.ADOLC_rec.track3D.std(end);
% h3 = barwitherr(iter_ratio_4plots.ADOLC_rec.std,iter_ratio_4plots.ADOLC_rec.mean);
% set(gca,'Fontsize',label_fontsize);  
% set(gca,'XTickLabel',{'P2','P3','P4','P5','P6','P7','P8','P9','P10','Pr','Tr'},'Fontsize',label_fontsize');
% ylabel('Number of iterations','Fontsize',label_fontsize');
% ylim([0 2]);
% box off;
% subplot(2,2,4)
% iter_ratio_4plots.FD_rec.mean = zeros(1,length(ww_pend));
% iter_ratio_4plots.FD_rec.std = zeros(1,length(ww_pend));
% for k = 2:length(ww_pend)+1
%     iter_ratio_4plots.FD_rec.mean(1,k-1) = iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).mean(end);
%     iter_ratio_4plots.FD_rec.std(1,k-1) = iter_ratio.FD_rec.(['pendulum',num2str(k),'dof']).std(end);
% end
% iter_ratio_4plots.FD_rec.mean(1,end+1) = iter_ratio.FD_rec.pred2D.mean(end);
% iter_ratio_4plots.FD_rec.mean(1,end+1) = iter_ratio.FD_rec.track3D.mean(end);
% iter_ratio_4plots.FD_rec.std(1,end+1) = iter_ratio.FD_rec.pred2D.std(end);
% iter_ratio_4plots.FD_rec.std(1,end+1) = iter_ratio.FD_rec.track3D.std(end);
% h4 = barwitherr(iter_ratio_4plots.FD_rec.std,iter_ratio_4plots.FD_rec.mean);
% set(gca,'Fontsize',label_fontsize);  
% set(gca,'XTickLabel',{'P2','P3','P4','P5','P6','P7','P8','P9','P10','Pr','Tr'},'Fontsize',label_fontsize');
% % ylabel('Number of iterations','Fontsize',label_fontsize');
% ylim([0 2]);
% box off;

%% Analyze CPU time and iterations
CPU_pend_all.all = [];
for k = 2:length(ww_pend)+1    
    CPU_pend_all.all = [CPU_pend_all.all;t_proc_all.(['pendulum',num2str(k),'dof']).Rec.all(:,end)];
end
CPU_pend_all.min = min(CPU_pend_all.all);
CPU_pend_all.max = max(CPU_pend_all.all);

iter_pend_all.all = [];
for k = 2:length(ww_pend)+1    
    iter_pend_all.all = [iter_pend_all.all;n_iter_all.(['pendulum',num2str(k),'dof']).Rec.all(:,end)];
end
iter_pend_all.min = min(iter_pend_all.all);
iter_pend_all.max = max(iter_pend_all.all);

% FD

CPU_pend_all.all = [];
for k = 2:length(ww_pend)+1    
    CPU_pend_all.all = [CPU_pend_all.all;t_proc_all.(['pendulum',num2str(k),'dof']).FD.all(:,end)];
end
CPU_pend_all.min = min(CPU_pend_all.all);
CPU_pend_all.max = max(CPU_pend_all.all);

iter_pend_all.all = [];
for k = 2:length(ww_pend)+1    
    iter_pend_all.all = [iter_pend_all.all;n_iter_all.(['pendulum',num2str(k),'dof']).FD.all(:,end)];
end
iter_pend_all.min = min(iter_pend_all.all);
iter_pend_all.max = max(iter_pend_all.all);

    
