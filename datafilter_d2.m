%DataFilter D2 Function

function [butterCompliance1,butterTime1,butterCompliance2,butterTime2,butterCompliance3,butterTime3] = datafilter_d2(compliance,time)

filter_approve = 0;

while filter_approve == 0
    close all
    
    %index puls postions, (x and y)
    x = [0,0,0,0];
    y = [0,0,0,0];
    
    %To be alterd by group
    fs = 50; %sampling rate of 50Hz
    fc = 0.75; %cut-off frequency of 0.75
    
    %Designs a low pass IIR(infinite impulse response) filter with the
    %previously inputted frequency valuse
    %Low Pass ButterWorth Filter Design
    d1 = designfilt('lowpassiir', 'FilterOrder', 2, 'HalfPowerFrequency', fc,...
        'DesignMethod', 'butter', 'SampleRate', fs); 
    
    butterworth = filtfilt(d1, compliance) %rough filter data set
    figure(1);
    a1 = plot(time, compliance); %raw time vs compliance
    hold on
    a2 = plot(time, butterworth1, 'r', 'LineWidth', 2); %filtered time vs compliance
    legend(a, 'Raw Data', 'Quick Filtered Data')
    xlabel('Time');
    ylabel('Compliance');
    
    %user quality check
    quality_check = input('Is data adequate quality? Y/N', 's'); 
    
    if quality_check == 'Y' || quality_check == 'y'
        fprintf('Please select a point around the middle of the correct pulse\n');
        figure(1);
        plot(time, compliance);
        hold on
        [xp,~] = ginput(1); %selected point
        pk_i = round((50*round(xp/0.02)/50)+1); %position of the midpoint of 1st pulse
        
        %if midpoint before 3 secs set it a 3 to prevent error
        if pk_i <= 150
            pk_i = 151;
        end
        
        %ask the user to select start of rising pusle being shown raw data
        %from the before mid-pulse to the mid-pulse
        %if the user can't find the rising edge, prompt to click under
        %x-axis
        figure(2)
        plot(time, compliance, 'b')
        %only show data from 800 before to up until rising pulse
        axis([time(abs(pk_i-800)), time(pk_i), min(compliance), max(compliance(abs(pk_i-800):pk_i))]);
        hold on
        fprintf('Please select start of rising pulse\n');
        fprintf('If cant find rising pulse, click below xaxis\n');
        title('Please select start of rising pulse');
        [x(1),y(1)] = ginput(1);
        rise1 = round((50*(round(x(1)/0.02)/50))+1); %start of rising pulse position
        
        if y(1)>min(compliance) %continue if user found start of pulse
            figure(2)
            hold on
            plot(time(rise1), compliance(rise1), 'ok');
            fprintf('Point selected at %.2f seconds and position %d\n', time(rise1), rise1)
            
            %ask user to select end of rising edge, and if not below xaxis
            figure(2)
            plot(time, compliance, 'b');
            axis([time(abs(pk_i-800)), time(pk_i), min(compliance), max(compliance(abs(pk_i-800):pk_i))]);
            hold on
            fprintf('Please select end of rising pulse\n');
            fprintf('If cant find rising pulse, click below xaxis\n');
            title('Please select end of rising pulse');
            [x(2), y(2)] = ginput(1);
            rise2 = round((50*(round(x(2)/0.02)/50))+1); %end of rising pulse position
            
            if y(2) > min(compliance) %continue if user found rising edge
                %plot end of rising edge
                figure(2)
                hold on 
                plot(time(rise2), compliance(rise2), 'ok');
                fprintf('Point selected at %.2f seconds and position %d\n', time(rise2), rise2)
                
                %Ask user to select end of falling edge on graph. If user
                %can't find falling edge, user is prompted to click under
                %xaxis
                figure(2)
                plot(time, compliance, 'b');
                axis([time(pk_i), time(pk_i+1500), min(compliance), max(compliance(pk_i:pk_i+800))]);
                hold on 
                fprintf('Please select end of falling pulse\n')
                fprintf('If cant find falling pulse, click anywhere below x-axis\n')
                title('Please select start of falling pulse')
                [x(3), y(3)] = ginput(1);
                rise3 = round((50*(round(x(3)/0.02)/50))+1); % start of falling edge position
                
                %continue if uses found rising and falling edge properly
                if y(3)>min(compliance)
                    
                end
            end
        end
    end
    
        
end
