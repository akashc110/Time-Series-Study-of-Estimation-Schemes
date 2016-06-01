clc;
clear all;
warning('off','all');
A = importdata('SP500.csv');
true_delta = diff(A);
length(true_delta)

SP500 = A(1:301);
figure
plot(SP500);
title('SP500 2014-15 Period Time Series');
xlabel('Time')
ylabel('Value')

%Augmented Dickey-Fuller Test for stationarity:
display('Augmented Dickey-Fuller Test for SP500 series:');
adftest(SP500)
if (adftest(SP500))==0
display('Null hypothesis is not rejected.');
display('The characteristic polynomial of the data has a unit root.');
display('The data is non-stationary');
end

delta_y = diff(SP500);
plot(delta_y);

%Augmented Dickey-Fuller Test for stationarity:
display('Augmented Dickey-Fuller Test for delta y:');
adftest(delta_y)
if (adftest(delta_y))==1
display('Null hypothesis is rejected.');
display('The characteristic polynomial of the data does not have a unit root.');
display('The data is stationary.');
end

%Test for Autocorrelation

autocorr(delta_y);
%figure();
autocorr(delta_y.^2);
display(lbqtest(delta_y));
if (lbqtest(delta_y))==0
display('Null is rejected');
display('So a series of residuals exhibit autocorrelation for a fixed number of lags');
end

%display(lbqtest(delta_y.^2));
if (lbqtest(delta_y.^2))==1
    display('Null is accepted');
    display('Series of squared residuals do not exhibit autocorrelation');
end

display('We proceed with GARCH (1,1) Model');

spec = garchset('VarianceModel','GARCH','P',1,'Q',1);
spec = garchset(spec, 'Distribution','Gaussian','Display','off');

[coeff, errors, LLF, efit, sFit] = garchfit(spec, delta_y);

garchdisp(coeff,errors);

horizon = 1;

%[sigmaForecast, meanForecast, sigmaTotal, meanRMSE] = ...
 %   garchpred(coeff,delta_y, horizon);

 %[sigmaForecast, meanForecast] = ...
  %     garchpred(coeff,delta_y, horizon);
%display(meanForecast);
%display(sigmaForecast);
%display(true_delta(301));
delta_y_rolling = delta_y;


%Recursive Estimation Method:

Forecast_values = [];
True_error = zeros(400);
for i=1:203
    
    Forecast_values = [];
    True_error = [];
    %Step 1: Forecast
        [sigmaForecast, meanForecast] = ...
       garchpred(coeff,delta_y, horizon);
   
        Forecast_values = vertcat(Forecast_values, meanForecast);
        True_error = vertcat(True_error, meanForecast - true_delta(300+i));
        
    %Step 2: Recalculate GARCH using true value for last observation:
    
        delta_y = vertcat(delta_y, true_delta(300+i));
        [coeff, errors, LLF, efit, sFit] = garchfit(spec, delta_y);
        
end
%plot(True_error);
%figure();
Mean_Squared_Forecast_Error = (sum(True_error.^2))/length(True_error);
display(Mean_Squared_Forecast_Error);


%Rolling Estimation Method:
Forecast_rolling = [];
Actual_error =[];
window_length = 300;

for j = 1:203
%Step 1: Forecast
        [sigmaForecast, meanForecast] = ...
       garchpred(coeff,delta_y_rolling, horizon);
   
       % Forecast_rolling = vertcat(Forecast_rolling, meanForecast);
        Actual_error = vertcat(Actual_error, meanForecast - true_delta(300+j));

%Step 2: Recalculate GARCH using true value for last observation:
    
        delta_y_rolling = vertcat(delta_y_rolling, true_delta(300+j));
        rolling_y = createRollingWindow(delta_y_rolling, window_length);
        roll_y = rolling_y';
       % display(length(roll_y));
        [coeff, errors, LLF, efit, sFit] = garchfit(spec, roll_y);

end
%plot(Actual_error);
%length(rolling_y)
MSFE_Rolling = (sum(Actual_error.^2))/length(Actual_error);
display(MSFE_Rolling);