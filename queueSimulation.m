function queueSimulation()

    
    % ---------- Getting the data from user ----------------------------------
    counter_selected  = input('Enter amount of counter open(1 ~ 3): ');
   
    disp('Choose the randomizer generator to use: ')
    disp('1. Linear Congruential Generator')
    disp('2. Multiplicative Congruential Generator')
    disp('3. Additive Congruential Generator')
    disp('4. Random variate generator for exponential distribution ')
    disp('5. Random variate generator for uniform distribution')
    get_randomizer = input('The randomizer generator use is(1 ~ 5): ');
    printf('\n\n\n')
    number_of_customers = feval('linearCongruentialGenerator',1,1,99)(1);
    %number_of_ticket = input('Enter the number of ticket for movie 1 ');
    interarrival_time_number       = 8;
    SERVICE_TIMES_NUMBER           = 5;
    NUM_OF_ITEM_TIMES              = 9;
    TICKET_SLOT_OR_DAY             = 6;
    TICKET_TYPE                    = 3;
    SERVICE_TIME_DEFAULT_BUMP      = 2; %set the default service time as 2
    ITEM_TIME_DEFAULT_BUMP         = 0;	%set the default service time as 0
    INTERARRIVAL_TIME_DEFAULT_BUMP = 0;	%set the default service time as 0
    SERVICE_TIME_RN_SIZE           = 100;
    INTERARRIVAL_TIME_RN_SIZE      = 100;
    ITEM_RN_SIZE                   = 100;
    ITEM_NUMBER_RN_SIZE            = 3;
    
    
    % variables to generate before main loop
    counter_service_times  = [];
    interarrival_times    = [];

    rn_service_times      = [];
    rn_interarrival_times = [];

        
    counter_ending_times              = zeros(1, counter_selected); % this is to track who ends first in the loop
    counter_spent_times               = zeros(1, counter_selected); % this is to track total time spent by each counter
    counter_number_of_customers       = zeros(1, counter_selected); % this is to track the num of customers who were served

    customer_interarrival_times  = zeros(1, number_of_customers);
    customer_arrival_times       = zeros(1, number_of_customers);
    customer_served_by           = zeros(1, number_of_customers); % this is to track ID of counters
    customer_service_begin_times = zeros(1, number_of_customers);
    customer_service_duration    = zeros(1, number_of_customers);
    customer_service_end_times   = zeros(1, number_of_customers);
    customer_queued_times        = zeros(1, number_of_customers);
    customer_total_spent_times   = zeros(1, number_of_customers); % queue + service

    % ---------------- data checking for all the data given by user ----------------
    % user select the generator 
    % return error message if user enter wrongly 
    % Remind user to pass in correct arguments
    if (~isset('counter_selected') || ~isset('number_of_customers'))
        error('To simulate with your own number of counters and customers, try calling it as such customerService(num_of_counters, num_of_customers, randomizer). For example: customerService(2, 15, "LinearCG")')
    end

    if ((counter_selected < 1) || (counter_selected >3 ) )
        error('num_of_counters must be more equal of more than 1 or less than 3.')
    end

    if (number_of_customers < 1)
        error('num_of_customers must be more equal of more than 1.')
    end

    % If randomizer is set, check whether randomizer function is available.
    % Default randomizer would be RVGUD
    if(get_randomizer == 1)
        randomizer = 'linearCongruentialGenerator';
    end
    if(get_randomizer == 2)
        randomizer = 'MultiplicativeCG';
    end
    if(get_randomizer == 3)
        randomizer = 'AdditiveCG';
    end
    if(get_randomizer == 4)
        randomizer = 'RVGED';
    end
    if(get_randomizer == 5)
        randomizer = 'RVGUD';
    end
    if ((get_randomizer < 1) || (get_randomizer > 5))
        error('Choose randomizer from 1 ~ 5 only');
    end
    % --------------- Generate ticket information --------------------------------------------------------
    ticketInformation(randomizer);
    % --------------- Generate service time for every counter ---------------------------------------------
    counter_service_times =  serviceTime(counter_selected,randomizer,counter_service_times);
    % --------------- Generate interarrival time --------------------------------------------------------
    for i = 1:1;
        % First we generate list of numbers ranging from 1 - 100
        interarrival_time_candidates = [];
        
        for j = 1:interarrival_time_number;
            interarrival_time_candidates(j) = feval(randomizer, 1, 1, INTERARRIVAL_TIME_RN_SIZE)(1);
        end

        % Find the denominator for the candidate numbers to divide against
        interarrival_time_candidates_sum = sum(interarrival_time_candidates);

        % Now make them random number range of 1 - 100
        interarrival_time_random_range = [];

        for j = 1:interarrival_time_number;
            interarrival_time_random_range(j) = round(100 * interarrival_time_candidates(j) / interarrival_time_candidates_sum);

            if (j >= 2);
                interarrival_time_random_range(j) = interarrival_time_random_range(j) + interarrival_time_random_range(j - 1);
            end
        end

        % Sometimes the range max may not end at 100, therefore to solve the issue:
        interarrival_time_random_range = interarrival_time_random_range + (100 - interarrival_time_random_range(interarrival_time_number));
        % Acquire random no range lower limit 
        randno_range_start=[];
        %Random no range always start with 1 ( 1 - *)
        randno_range_start(1)=1;

        for j = 1:interarrival_time_number;

            if j >= 2;
                start_point = interarrival_time_random_range(j - 1) + 1;
                %Stores the start point into an array for IAT Table 
                randno_range_start(j)=start_point;
            else;
                start_point = 1;
            end

            for k = start_point:interarrival_time_random_range(j);
                interarrival_times = [interarrival_times (j + i - 1 + INTERARRIVAL_TIME_DEFAULT_BUMP)];
            end

        end

    end

    % First generate the RN interarrival and RN service time
    rn_interarrival_times = feval(randomizer, number_of_customers, 1, SERVICE_TIME_RN_SIZE);
    rn_service_times      = feval(randomizer, number_of_customers, 1, INTERARRIVAL_TIME_RN_SIZE);

    % ----------------- Generate Interarrival Table---------------------------------------------
    printf('INTERARRIVAL TABLE\n')
    disp('|==================================================|')
    disp('|Interarrival | Probability | CDF    | Random No   |')
    disp('|Time         |             | F(X)   | Range       |')
    disp('|==================================================|')
    
    interarrival_time_random_range=interarrival_time_random_range/100;
    interarrival_time_random_range=interarrival_time_random_range';
    
    probability=[];
    probability(1)=interarrival_time_random_range(1);
    for i =1:interarrival_time_number-1;
        j=i+1;
        probability(j)=interarrival_time_random_range(j)-interarrival_time_random_range(i);
    end

    
    randno_range_end=[];
    
    randno_range_end(interarrival_time_number)=100;
    for i = 1:(interarrival_time_number-1)
        j=i+1;
        randno_range_end(i)=randno_range_start(j)-1;
    end
    for i = 1:interarrival_time_number;
        printf('\t\t\t%d\t\t\t\t\t\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t%3d - %3d\n',[i probability(i) interarrival_time_random_range(i) randno_range_start(i) randno_range_end(i)])
    end
    disp('|==================================================|')
    printf('\n\n\n')
    
    % -----------------------------------------------------------------------------------------------------
     %this is to generate item number
    
     for i = 1:1;

        % First we generate list of numbers ranging from 1 - 100
        item_candidates = [];
        
        
        for j = 1:TICKET_SLOT_OR_DAY;
            item_candidates(j) = feval(randomizer, 1, 1, ITEM_RN_SIZE)(1);
        end
    
        %========================================
        % Find the denominator for the candidate numbers to divide against
        item_candidates_sum = sum(item_candidates);

        % Now make them random number range of 1 - 100
        item_random_range = [];

        for j = 1:TICKET_SLOT_OR_DAY;
            item_random_range(j) = round(100 * item_candidates(j) / item_candidates_sum);

            if (j >= 2);
                item_random_range(j) = item_random_range(j) + item_random_range(j - 1);
            end
        end

        % Sometimes the range max may not end at 100, therefore to solve the issue:
        item_random_range = item_random_range + (100 - item_random_range(TICKET_SLOT_OR_DAY));
        % Acquire random no range lower limit 
        randno_range_start=[];
        %Random no range always start with 1 ( 1 - *)
        randno_range_start(1)=1;
        %===========================================
        for j = 1:TICKET_SLOT_OR_DAY;

            if j >= 2;
                start_point = item_random_range(j - 1) + 1;
                %Stores the start point into an array for IAT Table 
                randno_range_start(j)=start_point;
            else;
                start_point = 1;
            end

            for k = start_point:item_random_range(j);
                item_times = [item_times (j + i - 1 + ITEM_TIME_DEFAULT_BUMP)];
            end

        end

    end

    % First generate the RN interarrival and RN service time
    rn_item_times = feval(randomizer, number_of_customers, 1, ITEM_RN_SIZE);
    rn_item_price = feval(randomizer, number_of_customers, 1, ITEM_RN_SIZE);

    %=====================================================
    
    % Generate Item Table
    fprintf('TABLE OF TICKET SLOT\n')
    disp('|===================================================|')
    disp('|Ticket        | Probability | CDF    | Random No   |')
    disp('|slot/day      |             | F(X)   | Range       |')
    disp('|===================================================|')
    
    item_random_range=item_random_range/100;
    item_random_range=item_random_range';
    
    probability=[];
    probability(1)=item_random_range(1);
    for i =1:TICKET_SLOT_OR_DAY-1;
        j=i+1;
        probability(j)=item_random_range(j)-item_random_range(i);
    end

    
    randno_range_end=[];
    
    randno_range_end(TICKET_SLOT_OR_DAY)=100;
    for i = 1:(TICKET_SLOT_OR_DAY-1)
        j=i+1;
        randno_range_end(i)=randno_range_start(j)-1;
    end
    
    item_random_price=[];
    for j = 1:9;
        item_random_price(j) = feval(randomizer, 1, 1, ITEM_RN_SIZE)(1);
    end
    
    
    
    for i = 1:TICKET_SLOT_OR_DAY;
        fprintf('\t\t\t%d\t\t\t\t\t\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t%3d - %3d\t\t\t\t\n',[i probability(i) item_random_range(i) randno_range_start(i) randno_range_end(i)])
    end
    disp('|===================================================|')
    fprintf('\n\n\n')
    
     % -----------------------------------------------------------------------------------------------------
     %this is to generate item number
    
     for i = 1:1;

        % First we generate list of numbers ranging from 1 - 100
        item_candidates = [];
        
        
        for j = 1:TICKET_TYPE;
            item_candidates(j) = feval(randomizer, 1, 1, ITEM_RN_SIZE)(1);
        end
    
        %========================================
        % Find the denominator for the candidate numbers to divide against
        item_candidates_sum = sum(item_candidates);

        % Now make them random number range of 1 - 100
        item_random_range = [];

        for j = 1:TICKET_TYPE;
            item_random_range(j) = round(100 * item_candidates(j) / item_candidates_sum);

            if (j >= 2);
                item_random_range(j) = item_random_range(j) + item_random_range(j - 1);
            end
        end

        % Sometimes the range max may not end at 100, therefore to solve the issue:
        item_random_range = item_random_range + (100 - item_random_range(TICKET_TYPE));
        % Acquire random no range lower limit 
        randno_range_start=[];
        %Random no range always start with 1 ( 1 - *)
        randno_range_start(1)=1;
        %===========================================
        for j = 1:TICKET_TYPE;

            if j >= 2;
                start_point = item_random_range(j - 1) + 1;
                %Stores the start point into an array for IAT Table 
                randno_range_start(j)=start_point;
            else;
                start_point = 1;
            end

            for k = start_point:item_random_range(j);
                item_times = [item_times (j + i - 1 + ITEM_TIME_DEFAULT_BUMP)];
            end

        end

    end

    % First generate the RN interarrival and RN service time
    rn_item_times = feval(randomizer, number_of_customers, 1, ITEM_RN_SIZE);
    rn_item_price = feval(randomizer, number_of_customers, 1, ITEM_RN_SIZE);

    %=====================================================
    
    % Generate Item Table
    fprintf('TABLE OF TICKET TYPE\n')
    disp('|=============================================|')
    disp('|Ticket      | Probability | CDF    | Range   |')
    disp('|type        |             | F(X)   |         |')
    disp('|=============================================|')
    
    item_random_range=item_random_range/100;
    item_random_range=item_random_range';
    
    probability=[];
    probability(1)=item_random_range(1);
    for i =1:TICKET_TYPE-1;
        j=i+1;
        probability(j)=item_random_range(j)-item_random_range(i);
    end

    
    randno_range_end=[];
    
    randno_range_end(TICKET_TYPE)=100;
    for i = 1:(TICKET_TYPE-1)
        j=i+1;
        randno_range_end(i)=randno_range_start(j)-1;
    end
    
    for i = 1:TICKET_TYPE;
        fprintf('\tmovie %d\t\t\t\t\t\t\t%2.2f\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t%3d - %3d\t\t\t\t\n',[i probability(i) item_random_range(i) randno_range_start(i) randno_range_end(i)])
    end
    disp('|=============================================|')
    fprintf('\n\n\n')
    
    %-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
     % Let's simulate all the customers arriving
    disp('|=========================================================================================================| ')
    disp('|n  |RN for | Interarrival | Arrival | RN for      | ticket    | RN for the  | No of ticket | Total       | ')
    disp('|   |inter  | Time         | Time    | ticket slot | slot/day  | ticket type | purchased    | amount paid | ')
    disp('|=========================================================================================================| ')

    for customer = 1:number_of_customers;

        % Calculate interarrival & arrival times
        if customer > 1;
            customer_interarrival_times(customer) = interarrival_times(rn_interarrival_times(customer));
            customer_arrival_times(customer) = customer_arrival_times(customer - 1) + customer_interarrival_times(customer);
        else
            customer_interarrival_times(customer) = 0;
            customer_arrival_times(customer)      = 0;
        end

        arrival_time = customer_arrival_times(customer);
        
        item_purchased(customer) = feval(randomizer, 1, 1, ITEM_NUMBER_RN_SIZE)(1);  
      
        item_random_number(customer) = randperm(9);
      
        customer_total_price(customer) =  item_random_price(item_random_number(customer))*item_random_number(customer);

        % Print result
        printf('%3d \t\t %3d \t\t\t\t\t\t %3d \t\t\t\t\t\t %3d \t\t\t\t\t\t\t %3d \t\t\t\t\t\t\t\t\t %3d \t\t\t\t\t\t\t\t\t\t %3d \t\t\t\t\t\t\t\t\t\t\t %3d \t\t\t\t\t\t\t %3d\n', [customer rn_interarrival_times(customer) customer_interarrival_times(customer) customer_arrival_times(customer) rn_interarrival_times(customer) item_purchased(customer) item_random_number(customer) item_random_number(customer) customer_total_price(customer) ])

    end;
    
    disp('|=========================================================================================================| ')
    printf('\n\n\n')
    %----------------------------------------------------------------------------------------------------------------------------------------------------
    
     

    
    % Let's simulate all the customers arriving
    disp('|===========================================================================================|')
    disp('|n | Interarrival | Arrival | Queued | Counter | Service | Service  | Service | Total     |')
    disp('|  | Time         | Time    | Time   | Number | Starts  | Duration | Ends    | Time Spent|')
    disp('|===========================================================================================|')

    for customer = 1:number_of_customers;

        % Calculate interarrival & arrival times
        if customer > 1;
            customer_interarrival_times(customer) = interarrival_times(rn_interarrival_times(customer));
            customer_arrival_times(customer) = customer_arrival_times(customer - 1) + customer_interarrival_times(customer);
        else
            customer_interarrival_times(customer) = 0;
            customer_arrival_times(customer)      = 0;
        end

        arrival_time = customer_arrival_times(customer);

        % Get a free counter, or soonest-to-be-free
        chosen_counter = [0 (number_of_customers*100)]; % [counter_id counter_ending_time]

        for i = 1:counter_selected;
            if (counter_ending_times(i) < chosen_counter(2));
                chosen_counter = [i counter_ending_times(i)];
            end
        end

        % Special case for 1st customer 1st counter, to avoid potentially slower counters:
        if counter_service_times(1) == 0;
            chosen_counter = [1 0];
        end

        chosen_counter_id          = chosen_counter(1);
        chosen_counter_ending_time = chosen_counter(2);

        % Counter found
        customer_served_by(customer) = chosen_counter_id;
        customer_service_duration(customer) = counter_service_times(chosen_counter_id, rn_service_times(customer));

        % Calculate the times
        customer_service_begin_times(customer) = max([arrival_time chosen_counter_ending_time]);
        customer_service_end_times(customer)   = customer_service_begin_times(customer) + customer_service_duration(customer);
        customer_queued_times(customer)        = customer_service_begin_times(customer) - arrival_time;
        customer_total_spent_times(customer)   = customer_service_end_times(customer) - arrival_time;

        % Update server's int
        counter_number_of_customers(chosen_counter_id) = counter_number_of_customers(chosen_counter_id) + 1;
        counter_spent_times(chosen_counter_id)      = counter_spent_times(chosen_counter_id) + customer_service_duration(customer);

        % Update counter ending time
        counter_ending_times(chosen_counter(1)) = customer_service_end_times(customer);

        % Print result
        printf('\t%3d \t\t\t\t\t\t %3d \t\t\t\t\t\t %3d \t\t\t\t %3d \t\t\t\t %3d \t\t\t\t\t\t %3d \t\t\t\t\t %3d \t\t\t\t\t %3d \t\t\t\t\t\t\t %3d\n', [customer customer_interarrival_times(customer) customer_arrival_times(customer) customer_queued_times(customer) customer_served_by(customer) customer_service_begin_times(customer) customer_service_duration(customer) customer_service_end_times(customer) customer_total_spent_times(customer)])

    end;
    disp('|===========================================================================================|')
    
    
    %Timeline
    printf('\n\n\n');
    disp('|===========================================================================================|')
    disp('|                               DISCRIPTION OF CUSTOMERS                                    |')
    disp('|===========================================================================================|')
    printf('\n\n');
    for customer = 1:number_of_customers;
        printf('Customer %d arrives at minute %d and queues at Counter %d\n',customer,customer_arrival_times(customer),customer_served_by(customer));
        printf('Service Time is %d and Service starts at %d\n',customer_service_duration(customer),customer_service_begin_times(customer));
        printf('Customer %d departs at %d\n\n',customer,customer_service_end_times(customer));
    end
    
    disp('|===========================================================================================|')
    %-------------------------------------------------------------------------------------------------------------------------------------------------------
    printf('\n\n')
    disp('|========================================|')
    printf('| SUMMARY OF THE COUNTERS                 |\n');
    disp('|========================================|')
    % Testing
    printf('\n\n');
    %Initialize counter_busy array
    counter_busy=[]; 
    for counter = 1:counter_selected;
        printf('Counter %d spent total of %d minutes serving total of %d customers.\n', [counter counter_spent_times(counter) counter_number_of_customers(counter)]);
        counter_busy(counter)=(counter_spent_times(counter)/customer_service_end_times(number_of_customers))* 100;
        printf('Percentage of Counter %d being busy is %2.2f percent.\n\n',counter,counter_busy(counter))
    end

    printf('\n');
    %----------------------------------------------------------------------------------------------------------------------------------------------------
    % Avergae customer waiting time + Chance of them queueing up
    customer_avg_queue_time = mean(customer_queued_times);
    percentage_of_customers_queue_up = 100 * length(nonzeros(customer_queued_times)) / number_of_customers;
    disp('|========================================|')
    printf('| SUMMARY OF THE CUSTOMER SERVICE SYSTEM |\n');
    disp('|========================================|')
    printf('\n\n')
    printf('%3.2f percent of customers have spent time queueing up\n', [percentage_of_customers_queue_up]);
    printf('Average waiting time: %5.2f\n', [customer_avg_queue_time])

    % Average service time
    customer_avg_service_time = mean(customer_service_duration);
    customer_avg_interarrival_time = mean(customer_interarrival_times);
    customer_avg_spent_time = mean(customer_total_spent_times);

    printf('Average service time of each counter: %5.2f\nAverage interarrival time: %5.2f\nAverage time customer spent in Customer Service System: %5.2f\n\n\n', [customer_avg_service_time customer_avg_interarrival_time customer_avg_spent_time]);

	
	%Summary
    disp('Conclusion drawn:')
    if (percentage_of_customers_queue_up <= 25)
        disp('Customers have a low chance of waiting in queue.')
    elseif (percentage_of_customers_queue_up > 25 && percentage_of_customers_queue_up <= 50)
        disp('Customers have a moderate chance of waiting in queue.')
    elseif (percentage_of_customers_queue_up > 50 && percentage_of_customers_queue_up <= 75)
        disp('Customers have a high chance of waiting in queue.')
    else
        disp('Customers have a very high chance of waiting in queue.')            
    end