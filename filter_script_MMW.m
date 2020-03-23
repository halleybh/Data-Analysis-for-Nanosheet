close all; clc;

radius = 2.25e-6;
force = 6e-9;
csa = 2*pi*radius;

medMW_cell = struct2cell(StructSum);

displacement = (medMW_cell{12}.r_nm).*1e-9;
time = medMW_cell{12}.time;

strain = displacement/radius;
stress = force/csa;
compliance = strain/stress;

[comp1,time1,comp2,time2,comp3,time3] = datafilter_d1(compliance,time);

comp = [comp1' comp2'];
time = [time1 time2];

[E0_4, E1_4,tau0_4,tau1_4,RegComp4] = BMRegress_4(comp, time);
[E0_6,E1_6,E2_6,tau0_6,tau1_6,tau2_6,RegComp6] = BMRegress(comp,time);

% Calculate average error for four element model

for i = 1:length(RegComp4)
    error4(i) = RegComp4(i) - comp(i);
end

mean_error4 = (sum(abs(error4), 'all'))/(length(error4))

% Calculate average error for six element model

for i = 1:length(RegComp6)
    error6(i) = RegComp6(i) - comp(i);
end

mean_error6 = (sum(abs(error6), 'all'))/(length(error6))



