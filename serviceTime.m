function output = serviceTime(counter_selected,randomizer,counter_service_times)

    SERVICE_TIME_DEFAULT_BUMP      = 2; %set the default service time as 2
    SERVICE_TIMES_NUMBER           = 5;
    SERVICE_TIME_RN_SIZE           = 100;

    

    for i = 1:counter_selected;
        %this for loop is to do things based on how many counter_selected from the user   
            
            counter_minimum_service_time = i + SERVICE_TIME_DEFAULT_BUMP;
    
            % First we generate a list of numbers ranging from 1 - 100
            service_time_candidates = [];
            for j = 1:SERVICE_TIMES_NUMBER;
                service_time_candidates(j) = feval(randomizer, 1, 1, SERVICE_TIME_RN_SIZE)(1);
                %using feval to call the randomizer function indirectly.
            end
    
            % Find the denominator for the candidate numbers to divide against
            service_time_candidates_sum = sum(service_time_candidates);
    
            % Now make them random number range of 1 - 100
            service_time_random_range = [];
    
            for j = 1:SERVICE_TIMES_NUMBER;
                service_time_random_range(j) = round(100 * service_time_candidates(j) / service_time_candidates_sum);
    
                if (j >= 2);
                    service_time_random_range(j) = service_time_random_range(j) + service_time_random_range(j - 1);
                end
            end
    
            % Sometimes the range max may not end at 100, therefore to solve the issue:
            service_time_random_range = service_time_random_range + (100 - service_time_random_range(SERVICE_TIMES_NUMBER));
    
            % Now we generate a vector of service times that appears at the frequency of service time random range
            service_time = [];
            %Initialise array for random no range
            service_randno_range_start=[];
            %Random no range always start with 1 ( 1 - *)
            service_randno_range_start(1)=1;
    
            for j = 1:SERVICE_TIMES_NUMBER;
    
                if j >= 2;
                    
                    %this is to generate the start points of every counter
                    %following start point add service time range + 1 (end point != start point of next ,so +1 )become next start point 
                    
                    start_point = service_time_random_range(j - 1) + 1;
                   
                    service_randno_range_start(j)=start_point;
                else;
                    start_point = 1;
                end
                
                for k = start_point:service_time_random_range(j);
    
                    service_time = [service_time (j + i - 1)];
                    
                end
    
            end
    
            % Bump
            
            service_time = service_time + counter_minimum_service_time;
    
            % Lets put these data into counter[]
            
            counter_service_times = [counter_service_times; service_time];
            output = counter_service_times;
            %Generate CDF,F(x)  
            service_time_random_range=service_time_random_range/100;
            service_time_random_range=service_time_random_range';
            %Calculate Probability from randomly generated CDF
            
            %Calculate service time
    
            counter_probability=[];
            counter_probability(1)=service_time_random_range(1);
            for pa = 1:SERVICE_TIMES_NUMBER-1;
                pb=pa+1; %pa =probability after || probability before
                counter_probability(pb)=service_time_random_range(pb)-service_time_random_range(pa);   
            end
    
            service_randno_range_end=[];
            
            service_randno_range_end(SERVICE_TIMES_NUMBER)=100;
            for startrange = 1:SERVICE_TIMES_NUMBER-1;
                endrange=startrange+1;
                service_randno_range_end(startrange)=service_randno_range_start(endrange)-1;
            end
    
            fprintf('\nCounter %d Service Time\n',i)
            disp('|--------------------------------------------------|')
            disp('|Service      | Probability | CDF    | Random No   |')
            disp('|Time         |             | F(X)   | Range       |')
            disp('|--------------------------------------------------|')
            
            for j = 1:SERVICE_TIMES_NUMBER             
                fprintf('\t\t\t%2d\t\t\t\t\t\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t\t\t\t%2.2f\t\t\t\t%3d - %3d\n',[counter_minimum_service_time,counter_probability(j),service_time_random_range(j) service_randno_range_start(j) service_randno_range_end(j)])
                counter_minimum_service_time = counter_minimum_service_time+1;
            end
            disp('|--------------------------------------------------|')
            fprintf('\n\n')    
        
        end
    
   