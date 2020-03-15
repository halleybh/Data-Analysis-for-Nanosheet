close all; clc;

load('StructSumHighMW.mat');

radius = 14e-6;
force = 6e-9;
csa = 2*pi*radius;

%Cell 15 gives a good result

disp15 = StructSum.Cell23.r_nm;
time15 = StructSum.Cell23.time;

strain15 = disp15/radius;
stress15 = force/csa;
compliance15 = strain15/stress15;
creep15 = (pi*disp15*radius)/force;

plot(time15,compliance15);
grid on;
xlabel('Time (s)');
ylabel('Compliance (Pa^-^1)');

[butterCompliance1,butterTime1,butterCompliance2,butterTime2,butterCompliance3,butterTime3]=datafilter_d1(compliance15,time15);

time_matrix = [butterTime1 butterTime2 butterTime3];
compliance_matrix = [butterCompliance1' butterCompliance2' butterCompliance3'];

size_comp = size(compliance_matrix);
jump = zeros(2,2);
difference = 5e11;

for i=2:size_comp(1,2)
    if compliance_matrix(i)-compliance_matrix(i-1) > difference
        jump(1,1) = compliance_matrix(i-1);
        jump(1,2) = compliance_matrix(i);
        jump(2,1) = time_matrix(i-1);
        jump(2,2) = time_matrix(i);
        break
    end
end

% Create data points for rising edge

jump_points = zeros(50,2);

for i=1:50
    
    jump_points(i,1) = jump(2,1) + i*(jump(2,2) - jump(2,1))/50;
    jump_points(i,2) = jump(1,1) + i*(jump(1,2) - jump(1,1))/50;
    
end

% Create data points for falling edge

fall = zeros(2,2);

for i=2:size_comp(1,2)
    if compliance_matrix(i-1)-compliance_matrix(i) > difference
        fall(1,1) = compliance_matrix(i-1);
        fall(1,2) = compliance_matrix(i);
        fall(2,1) = time_matrix(i-1);
        fall(2,2) = time_matrix(i);
        break
    end
end

fall_points = zeros(50,2);

for i=1:50
    
    fall_points(i,1) = fall(2,1) + i*(fall(2,2) - fall(2,1))/50;
    fall_points(i,2) = fall(1,1) - i*(fall(1,1) - fall(1,2))/50;
    
end

plot(time_matrix, compliance_matrix);
hold on;
plot(jump_points(:,1), jump_points(:,2), 'o');
plot(fall_points(:,1), fall_points(:,2), 'o');

jump_fall_times = vertcat(jump_points(:,1), fall_points(:,1));

interpol_time = [time_matrix jump_fall_times'];

jump_fall_compliances = vertcat(jump_points(:,2), fall_points(:,2));

interpol_compliance = [compliance_matrix jump_fall_compliances'];

figure()
plot(interpol_time,interpol_compliance,'o'); 

