%% plots the Exercise results
% import the dymload util
addpath('c:\Program Files\Dymola 2021\Mfiles\dymtools\')

datafile = '../../Results2/imp_stepEx_normal.sdf';
hi = h5info(datafile)
%%
mmHg2SI = 133.322;
ml2SI = 1e-6;
bpm2SI = 1/60;
mlPmin2SI = 1/1000/60;

dl = datafile
time = h5read(dl, '/Time');
t_interval = [0, 60]; % interval in seconds
td = t_interval(2) - t_interval(1);
% i_int = [find(t >= t_interval(1), 1), find(t >= t_interval(2), 1)-1];
i_int = time >= 2; % get rid of the initial zeros

safezone = 400;
% %%
% g = hi.Groups(11)
% for i = 1:size(g.Groups, 1)
%     disp(num2str(i) + ":" + g.Groups(i).Name)
% end
%% EXERCISE VALUES
t = time;
pb = h5read(dl, '/brachial_pressure')/mmHg2SI;

pbs = h5read(dl, '/brachial_pressure_systolic')/mmHg2SI;
pbs(1:safezone) = pbs(safezone);
pbd = h5read(dl, '/brachial_pressure_diastolic')/mmHg2SI;
pbd(1:safezone) = pbd(safezone);
pbm = h5read(dl, '/brachial_pressure_mean')/mmHg2SI;
pbm(1:safezone) = pbm(safezone);
psa = h5read(dl, '/heartComponent/sa/pressure')/mmHg2SI;

hr = h5read(dl, '/HR')/bpm2SI;
lsv = h5read(dl, '/SV')/ml2SI;
% rsv = h5read(dl, '/heartComponent/pulmonaryValve/SV')/ml2SI;
plv = h5read(dl, '/P_LV')/mmHg2SI;
prv = h5read(dl, '/heartComponent/ventricles/P_RV')/mmHg2SI;
vlv = h5read(dl, '/heartComponent/ventricles/V_LV')/ml2SI;
vrv = h5read(dl, '/heartComponent/ventricles/V_RV')/ml2SI;
vla = h5read(dl, '/V_la')/ml2SI;

pla = h5read(dl, '/P_LA')/mmHg2SI;

psv = h5read(dl, '/P_sv')/mmHg2SI;
ppv = h5read(dl, '/P_pv')/mmHg2SI;
ppa = h5read(dl, '/heartComponent/pa/pressure')/mmHg2SI;

pra = h5read(dl, '/heartComponent/tricuspidValve/q_in/pressure')/mmHg2SI;
vra = h5read(dl, '/heartComponent/ra/volume')/ml2SI;


tp = h5read(dl, '/thoracic_pressure')/mmHg2SI;
pdv = h5read(dl, '/SystemicComponent/femoral_vein_R34/port_a/pressure')/mmHg2SI;
psv = h5read(dl, '/P_sv')/mmHg2SI - tp;
ppv = h5read(dl, '/P_pv')/mmHg2SI - tp;
el = h5read(dl, '/Exercise/y_')*100;
qmv = h5read(dl, '/q_mv')/ml2SI/1000*60;

pow_lv = h5read(dl, '/heartComponent/ventricles/power_LV');
pow_rv = h5read(dl, '/heartComponent/ventricles/power_RV');

co = h5read(dl, '/CO')/mlPmin2SI;
q_ex = h5read(dl, '/q_exercised_avg')/mlPmin2SI;

%% READ NORMAL FOR COMPARISON
datafile_n = '../../Results2/CardiovascularSystem.mat'
dl_n = dymload(datafile_n)
time_n = dymget(dl_n, 'Time');
t_interval_n = [58.13, 58.13 + 1.6]; % interval in seconds
td_n = t_interval_n(2) - t_interval_n(1)
% i_int = [find(t >= t_interval(1), 1), find(t >= t_interval(2), 1)-1];
i_int_n = (time_n >= t_interval_n(1) & time_n <= t_interval_n(2));

t_n = time_n - t_interval_n(1);
pb_n = dymget(dl_n, 'brachial_pressure')/mmHg2SI;
psa_n = dymget(dl_n, 'heartComponent.sa.pressure')/mmHg2SI;
plv_n = dymget(dl_n, 'heartComponent.mitralValve.q_out.pressure')/mmHg2SI;
pla_n = dymget(dl_n, 'heartComponent.mitralValve.q_in.pressure')/mmHg2SI;

psv_n = dymget(dl_n, 'P_sv')/mmHg2SI;
ppv_n = dymget(dl_n, 'P_pv')/mmHg2SI;


vlv_n = dymget(dl_n, 'V_LV')/ml2SI;
vla_n = dymget(dl_n, 'V_la')/ml2SI;

ppa_n = dymget(dl_n, 'heartComponent.pa.pressure')/mmHg2SI;
prv_n = dymget(dl_n, 'heartComponent.tricuspidValve.q_out.pressure')/mmHg2SI;
pra_n = dymget(dl_n, 'heartComponent.tricuspidValve.q_in.pressure')/mmHg2SI;

vrv_n = dymget(dl_n, 'heartComponent.ventricles.V_RV')/ml2SI;
vra_n = dymget(dl_n, 'heartComponent.ra.volume')/ml2SI;

qmv_n = dymget(dl_n, 'q_mv')/ml2SI/1000*60;


%% plot pv loops
ts = 35
te = 36.6
td = te - ts;
diffs = [1; find( diff(el) > 0)]
figure(3); clf;hold on;
ef = [];
edv = [];
pow_lvs = [];
pow_rvs = [];
co_s = [];
q_ex_s = [];

for i = 1:size(diffs)
%      i = 9

    i_s = find(time > time(diffs(i)) + ts, 1);
    i_e = find(time > time(diffs(i)) + te, 1);
%     t = time - time(i_s);
    i_int = [i_s:i_e];
    if i == 9
        t = time - time(i_s);
        i_int90 = i_int;
    end
%     plot(vlv(i_s:i_e), plv(i_s:i_e))
%     plot(vrv(i_s:i_e), prv(i_s:i_e))
%     plot(vla(i_s:i_e), pla(i_s:i_e))
    sv =  max(vlv(i_s:i_e)) -  min(vlv(i_s:i_e));
    ef = [ef, sv / max(vlv(i_s:i_e))];
    edv = [edv, min(vlv(i_s:i_e))];
    pow_lvs = [pow_lvs , pow_lv(i_s)];
    pow_rvs = [pow_rvs , pow_rv(i_s)];
    co_s = [co_s, mean(co(i_int))];
    q_ex_s = [q_ex_s, mean(q_ex(i_int))];
end

% plot([0:10:100], edv, 'b*-')
% plot([0:10:100], pow_rvs, 'r*-')
% plot([0:10:100], pow_lvs, 'b*-')
% plot([0:10:100], ef*10, 'b*-')
plot([0:10:100], co_s, 'b*-')
plot([0:10:100], q_ex_s, 'r*-')
% title('Ejection fraction on exercise level')

%% DRAW
fig1 = figure(1);clf;
set(gcf, 'DefaultAxesFontSize', 10);

s_a1 = subplot(4, 2, 1);
hold on;
title('A: Systemic pressures and volumes');
plot(t(i_int90), plv(i_int90), 'k', 'LineWidth', 1);
plot(t(i_int90), psa(i_int90), 'r', 'LineWidth', 1);
plot(t(i_int90), pb(i_int90), 'b', 'LineWidth', 1);
plot(t(i_int90), pla(i_int90), 'm', 'LineWidth', 1);
set(gca,'xtick',[])
leg = legend('P LV', 'P Asc Aor', 'PA (brach art)', 'P LA', 'Location', 'SouthEast')
leg.ItemTokenSize = [10, 150];
% legend('boxoff')
ylim([0, 220]);
ylabel('Pressure (mmHg)')
s_a1.Clipping = 'off';
xlim([0 td])
    
% volumes
s_a2 = subplot(4, 2, 3);hold on;
plot(t(i_int90), vlv(i_int90), 'b', 'LineWidth', 1);
plot(t(i_int90), vla(i_int90), 'r', 'LineWidth', 1);
leg = legend('V LV', 'V LA');
leg.ItemTokenSize = [10, 2];
set(gca,'xtickMode', 'auto')
ylim([0, 250]);
xlim([0 td])
xlabel('t (s)');
ylabel('Volume (ml)')
s_a1.Clipping = 'off';
% pos = get(s1, 'Position');
% set(s1, 'Position', [0.05, 0.5, 0.9,0.4])
% set(s2, 'Position', [0.05, 0.05, 0.9,0.4])

% B - venous plots
s_b1 = subplot(4, 2, 2);cla;
hold on;
title('B: Pulmonary and venous pressures');
plot(t(i_int90), psv(i_int90), 'b', 'LineWidth', 1);
plot(t(i_int90), ppv(i_int90), 'r', 'LineWidth', 1);
plot(t_n(i_int_n), psv_n(i_int_n), 'b:', 'LineWidth', 1);
plot(t_n(i_int_n), ppv_n(i_int_n), 'r:', 'LineWidth', 1);
s_b1.Clipping = 'off';
% set(gca,'xtick',[], 'ytick', [])
set(gca,'xtick',[], 'ytick', [5, 10, 15])
leg = legend('P SV E', 'P PV E', 'P SV N', 'P PV N')
leg.ItemTokenSize = [10, 2];
ylim([0, 20])
ylabel('Pressure [mmHg]')
xlim([0 td])

% Pulmonary arterial pressures
s_b2 = subplot(4, 2, 4);hold on;
plot(t(i_int90), ppa(i_int90), 'b', 'LineWidth', 1);
plot(t_n(i_int_n), ppa_n(i_int_n), 'b:', 'LineWidth', 1);
% set(gca,'xtickMode', 'auto', 'ytick', [])
ylim([0, 30]);
ylabel('Pressure [mmHg]')
xlim([0 td])
leg = legend('PPA E', 'PPA N')
leg.ItemTokenSize = [10, 2];
xlabel('t (s)');

% pos = get(s1, 'Position');
% set(s1, 'Position', [0.05, 0.5, 0.9,0.4])
% set(s2, 'Position', [0.05, 0.05, 0.9,0.4])

% C
s_c = subplot(2, 2, 3);cla;hold on;
title('C: Ventricle power during step-up exercise')
plot([0:10:100], pow_lvs, 'b*-', 'LineWidth', 1)
plot([0:10:100], pow_rvs, 'r*-', 'LineWidth', 1)
legend('LV', 'RV', 'Location', 'NorthWest')
xlabel('Exercise [% of max]');
ylabel('Power [W]');

% D
s_d = subplot(2, 2, 4);cla;hold on;
title('D: Cardiac output during step-up exercise')
% plot(vra(i_int), pra(i_int));
% plot(vla(i_int), pla(i_int));
plot([0:10:100], co_s, 'b*-', 'LineWidth', 1)
plot([0:10:100], q_ex_s, 'r*-', 'LineWidth', 1)
xlabel('Exercise (% of max)');
ylabel('Blood flow (L/min)');
leg = legend('Cardiac output', 'Flow through exercising tissues', 'Location', 'SouthEast')
leg.ItemTokenSize = [20, 150];
drawnow()

%% align the axis
drawnow()
pos = get(s_a2, 'Position');
tw = 17;
th = 14;
set(fig1, 'Units', 'Centimeters', 'Position', [2, 4, tw, th])

hm = 0.075;
vm = 0.08;
set(s_a1, 'Units', 'normalized', 'Position', [hm, 0.75, 0.5-1.2*hm,0.25 - vm/2])
set(s_a2, 'Units', 'normalized', 'Position', [hm, 0.5, 0.5-1.2*hm,0.25 - vm/2])

set(s_b1, 'Units', 'normalized', 'Position', [0.5 + hm, 0.75, 0.5-1.2*hm,0.25 - vm/2])
set(s_b2, 'Units', 'normalized', 'Position', [0.5 + hm, 0.5, 0.5-1.2*hm,0.25 - vm/2])

set(s_c, 'Units', 'normalized', 'Position', [hm, 1*vm, 0.5-1.2*hm,0.5 - 2.5*vm])
set(s_d, 'Units', 'normalized', 'Position', [0.5 + hm, 1*vm, 0.5-1.2*hm,0.5 - 2.5*vm])

% %% Draw boxes
% annotation(fig1,'rectangle', [0 0.5 0.5 0.5]);
% annotation(fig1,'rectangle', [0.5 0.5 0.5 0.5]);


%% save figure
exportgraphics(gcf,'fig_R_Exer.png','Resolution',200)
exportgraphics(gcf,'fig_R_Exer.pdf', 'ContentType','vector')
% tw = 17;
% th = 10;
% set(gcf, 'Units', 'Centimeters', 'Position', [0, 0, tw, th], 'PaperUnits', 'Centimeters', 'PaperSize', [tw, th])
% print(gcf,'fig_R_Exer_200.png', '-dpng', '-r200')

% saveas(gcf,'fig1.svg')