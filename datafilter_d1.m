%DataFilter D1 Function

function [butterCompliance1,butterTime1,butterCompliance2,butterTime2,butterCompliance3,butterTime3] = datafilter_d1(compliance,time)

filter_approve = 0;
kill = 0;

while filter_approve == 0
    close all;
    x = [0,0,0,0]; %vector will contain idex postions of pulse 
    y = [0,0,0,0]; %vector will contain corresponding y-coordinates
    
    %To be altered by group
    fs = 50; %sampling rate fo 50Hz
    fc = 0.75; %cut-off frequency of 0.75
    
    % Designs a low pass IIR (infinite impulse response) filter with the previously inputted frequency values
    d1 = designfilt('lowpassiir', 'FilterOrder', 2,...
    'HalfPowerFrequency', fc,'DesignMethod', 'butter',...
    'SampleRate',fs); %Low pass Butterworth Filter design

    %rough filter of whole data set
    butterworth1 = filtfilt(d1,compliance);
    
    figure(1);
    %plot time vs raw compliance
    a(1) = plot(time, compliance);                 
    hold on;
    %plot time vs filtered compliance over the raw data 
    a(2) = plot(time,butterworth1,'r','LineWidth',2); 
    legend(a, 'Raw data', 'Quick filtered data')
    xlabel('Time');
    ylabel('Compliance');
    
    %ask user for quality check
    quality_check = input('Is data adequate quality? Y/N', 's'); 
    
    if quality_check == 'Y' || quality_check == 'y'
        %ask for point
        fprintf('Please select a point around the middle of the correct pulse\n');
        figure(1);
        plot(time,compliance);
        hold on
        %user selected point input selected point
        [xp,~] = ginput(1); 
        %position of midpoint of 1st pulse rounded*
        pk_i = round((50*round(xp/0.02)/50)+1); 
        
        %if midpoint before 3 seconds set it at 3 sec to prevent error
        if pk_i <= 150
            pk_i = 151;
        end
        
        %ask user to select start of rising pulse being shown
        %raw data from ??? secs befroe mid-pulse to mid-pulse
        %if user can't find rising edge, prompt to click under x-axis
        figure(2)
        %data from 800 before to up until rising pulse
        plot(time,compliance,'b'); 
        axis([time(abs(pk_i-800)), time(pk_i), min(compliance), max(compliance(abs(pk_i-800):pk_i))]);
        hold on
        
        %ask for selection of start of rising pulse
        fprintf('Please select start of rising pulse \n');
        fprintf('If cant find rising pulse, click below xaxis\n');
        title('Please select start of rising pulse');
        %user selected point
        [x(1),y(1)] = ginput(1);
        %save start of rising pulse position rounded
        rise_pulse_i = round((50*(round(x(1)/0.02)/50))+1); 
        
        %loop if user found start of pulse
        if y(1)>min(compliance) 
            %plot pulse with user selected rising edge plotted
            figure(2)
            hold on
            plot(time(rise_pulse_i), compliance(rise_pulse_i),'ok');
            fprintf('Point selected at %.2f secdons and poisition %d\n',time(rise_pulse_i),rise_pulse_i)
            
            %plot edge again on new graph
            figure(2)
            plot(time,compliance,'b');
            axis([time(pk_i-800),time(pk_i), min(compliance), max(compliance(pk_i-800:pk_i))]);
            hold on
            %ask user to select end of rising edge
            fprintf('Please slecet end of rising pulse \n');
            fprintf('If cant find rising pulse, click below xaxis\n');
            title('Please select end of rising pulse');
            %user selected point
            [x(2), y(2)] = ginput(1);
            %end of rising pulse position rounded
            end_rise_pulse_i = round((50*(round(x(2)/0.02)/50))+1); 
        end
        
        %loop if user found rising and falling edge properly
        if y(1)>min(compliance) && y(2)>min(compliance) 
            %plot end of rising edge
            figure(2)
            hold on
            plot(time(end_rise_pulse_i), compliance(end_rise_pulse_i),'ok');
            fprintf('Point selected at %.2f seconds and position %d\n',time(end_rise_pulse_i), end_rise_pulse_i)
            
            %Ask user to select end of falling edge on graph. If user can't find
            %falling edge, user is prompted to click under x-axis
            figure(2)
            plot(time,compliance, 'b');
            axis([time(pk_i), time(pk_i+1500), min(compliance), max(compliance(pk_i:pk_i+800))]);
            hold on
            fprintf('Please select end of falling pulse \n')
            fprintf('If cannot find falling pulse, click anywhere below x-axis \n');
            title('Please select end of falling pulse')
            %user selected point
            [x(3),y(3)]=ginput(1);
            %end of falling edge position rounded
            fall_pulse_i=round((50*(round(x(3)/0.02)/50))+1); 
        end
        
        %loop if user found rising and falling edge properly
        if y(1)>min(compliance) && y(2)>min(compliance) && y(3)>min(compliance) 
            %plot start of falling edge edge
            figure(2)
            hold on
            plot(time(fall_pulse_i), compliance(fall_pulse_i),'ok');
            fprintf('Point selected at %.2f seconds and position %d\n',time(fall_pulse_i), fall_pulse_i)
            
            %Ask user to select start of falling edge on graph. If user can't find
            %falling edge, user is prompted to click under x-axis
            figure(2)
            plot(time,compliance, 'b');
            axis([time(pk_i), time(pk_i+1500), min(compliance), max(compliance(pk_i:pk_i+800))]);
            hold on
            fprintf('Please select start of falling pulse \n')
            fprintf('If cannot find falling pulse, click anywhere below x-axis \n');
            title('Please select start of falling pulse')
            %user selected point
            [x(4),y(4)]=ginput(1);
            %end of falling edge position rounded
            start_fall_pulse_i=round((50*(round(x(3)/0.02)/50))+1); 
            
            %plot end of rising edge
            figure(2)
            hold on
            plot(time(start_fall_pulse_i), compliance(start_fall_pulse_i),'ok');
            fprintf('Point selected at %.2f seconds and position %d\n',time(start_fall_pulse_i), start_fall_pulse_i)
        end    
    end
    
    %loop if user successfully found rising and falling edge
    if y(1)>min(compliance) && y(2)>min(compliance) && y(3)>min(compliance) && y(4)>min(compliance)

%commented out flipping pulses because wasn't working properly and skewing the data       
%         %correct if user pressed start and end wrong way round
%         if fall_pulse_i < start_fall_pulse_i
%             %flips pulses
%             fall_pulse_i = round((50*(round(x(4)/0.02)/50))+1);
%             start_fall_pulse_i = round((50*(round(x(4)/0.02)))+1);
%             fprintf('Error! End of falling edge cant be before the start');
%             %plot fliped
%             plot(time,complaince,time(rise_pulse_i:fall_pulse_i),compliance(rise_pulse_i:fall_pulse_i),'or')
%             title('User-selected Pulse')
%         end
%             
%         if rise_pulse_i > end_rise_pulse_i
%             %flip pulses
%             rise_pulse_i= round((50*(round(x(2)/0.02)/50))+1);
%             end_rise_pulse_i=round((50*(round(x(1)/0.02)/50))+1);
%             fprintf('Error! End of rising edge cannot be before the start of rising edge! This has been corrected for you! \n')
%             figure(4)
%             %plot fliped
%             plot(time, compliance, time(rise_pulse_i:fall_pulse_i),compliance(rise_pulse_i:fall_pulse_i), 'or')
%             title('User-selected pulse')
%         end
        
        %store important points of pulse
        rise1 = rise_pulse_i;
        rise2 = end_rise_pulse_i;
        fall1 = start_fall_pulse_i;
        fall2 = fall_pulse_i;
            
        %transpose data to 0
        transposed_pulse = compliance(end_rise_pulse_i:start_fall_pulse_i) - compliance(end_rise_pulse_i);
        transposed_disp = compliance(fall_pulse_i:fall_pulse_i+100) - mean(compliance(fall_pulse_i:fall_pulse_i+10));
            
        %filter in sections
        pre_buttered = filtfilt(d1, compliance(1:rise_pulse_i));
        peri_buttered = filtfilt(d1, transposed_pulse(1:end)) + compliance(end_rise_pulse_i);
        post_buttered = filtfilt(d1, transposed_disp(1:length(fall_pulse_i:fall_pulse_i+100))) + mean(compliance(fall_pulse_i:fall_pulse_i+10));
            
        %important time points in curve
        pre_pulse_times = 0:1/fs:1;
        rise_gap_time = (end_rise_pulse_i - rise_pulse_i)/fs;            
        pulse_time_start = 1 + rise_gap_time;
        pulse_time_end = ((start_fall_pulse_i - end_rise_pulse_i)/fs) + pulse_time_start;
        fall_gap_interval = (fall_pulse_i - start_fall_pulse_i)/fs;
        post_pulse_time_start = pulse_time_end + fall_gap_interval;
        post_pulse_time_end = post_pulse_time_start + 2;
        pulse_times = pulse_time_start:1 / fs:pulse_time_end;
        post_pulse_times = post_pulse_time_start:1 / fs:post_pulse_time_end;
            
        %remove any remenant magnetism (assume constant compliance)
        b = mean(pre_buttered(end-50:end));
        remMag1 = b.*ones(1,length(pre_pulse_times));
        remMag2 = b.*ones(1,length(pulse_times));
        remMag3 = b.*ones(1,length(post_pulse_times));
          
        %output sectioned filtered compliances
        butterCompliance1 = pre_buttered(end-50:end) - remMag1';
        butterCompliance2 = peri_buttered - remMag2';
        butterCompliance3 = post_buttered - remMag3';
            
        %output sectioned times
        butterTime1 = pre_pulse_times;
        butterTime2 = pulse_times;
        butterTime3 = post_pulse_times;
           
        %create unified filter pulse
        butter_filter = [butterCompliance1', butterCompliance2', butterCompliance3'];
        unified_time = [butterTime1, butterTime2, butterTime3];
        shiftedRawTime = time(rise_pulse_i-fs*1:fall_pulse_i+fs*2);
        shiftedRawCompliance = compliance(rise_pulse_i-fs*1:fall_pulse_i+fs*2) - mean(compliance(rise_pulse_i-fs*1:rise_pulse_i-fs*1+10));
         
        %plot unified pulses
        figure(11);
        t(1) = plot(shiftedRawTime-time(rise_pulse_i-fs*1),shiftedRawCompliance);
        hold on
        t(2) = plot(unified_time, butter_filter, 'g+-');
            
        title('Butterworth Lowpass Filter');
        grid on;
        xlabel('Time (s)');
        ylabel('Compliance (pa^-1)');
        legend(t, 'Raw Data', 'Filtered Data', 'Location', 'northwest');
            
        %final quality check
        filter_checker = input('Has data been filtered appropriately? Y/N','s');
            
        if filter_checker == 'Y' || filter_checker == 'y'
            %filter_approval= 1 so end funciton loop and exit
            filter_approve = 1;
        elseif filter_checker == 'N' || filter_checker == 'n'
            %if no filter well ask if they want to rerun the filtering
            filter_modifier = input('Would you like another attempt to filter? Y/N','s')
            if filter_modifier == 'Y' || filer_modifier == 'y'
                filter_approve = 0; %rerun function loop
            %if don't want to rerun filter make outputs 0
            elseif filter_modifier == 'N' || filer_modifier == 'n'
                fprintf('Dataset ignored, moving on! \n');
                %set functions to 0
                butterCompliance1 = 0;
                butterTime1 = 0;
                butterCompliance2 = 0;
                butterTime2 = 0;
                butterCompliance3 = 0;
                butterTime3 = 0;
                    
                %user has approved the discarding of dataset
                filter_approve = 0
                kill = 1;
            end
        end
        
    %if bad data set make outputs 0
    else
        fprintf('Dataset ignore, moving on! \n');
        
        %set functions to 0
        butterCompliance1 = 0;
        butterTime1 = 0;
        butterCompliance2 = 0;
        butterTime2 = 0;
        butterCompliance3 = 0;
        butterTime3 = 0;
        
        %user has approved the discarding of dataset
        filter_approve = 1;
        kill = 1;
    end
end
end


 