function [E0,E1,tau0,tau1,goodRegComp] = BMRegress_4(compliance,time)

xdata = time; 
ydata = compliance;
x0 = [0.1 0.1 0.1 0.1]; % initial guess for parameter values

lb = [0 0 0 0];
ub = [100 100 100 100];

MSE = 1000000;

% p = [E0 E1 E2 tau0 tau1 tau2]
fun = @(p,xdata)(1./(p(1))) + (1./(p(2))).*(1-exp((-xdata.*p(1)))./(p(4))) + xdata./p(3);

options = optimoptions('lsqcurvefit','FunctionTolerance',1e-8,'MaxFunctionEvaluations',1e5);
[params] = lsqcurvefit(fun,x0,xdata,ydata,lb,ub,options);

% build regressed curve
regComp = fun(params,xdata);

if (mean(abs(regComp-ydata))<MSE)
     MSE = mean(abs(regComp-ydata));
     E0 = params(1);
     E1 = params(2);
     tau0 = params(3);
     tau1 = params(4);
     goodRegComp = regComp;
end

regComp_posint = goodRegComp >= 0;
goodRegComp = goodRegComp(regComp_posint);
timeRC = xdata(regComp_posint);

% plot the result of the fit
figure;
plot(xdata,ydata);
hold on;
grid on;
plot(timeRC,goodRegComp,'r');
title('Four Element Burger Model');
xlabel('Time (s)')
ylabel('Compliance');
legend('Raw Data', 'Fitted Data');
end