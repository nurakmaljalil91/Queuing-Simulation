function queueSimulation()

    ticketInformation();
    counter_selected  = input('Enter amount of counter(1 ~ 3): ');
    printf('The number is %d \n',counter_selected);
    number_of_customers = input('Enter number of customers: ');
    printf('The number is %d \n',number_of_customers);
    disp('Choose the randomizer generator to use: ')
    disp('1. LinearCG')
    disp('2. MultiplicativeCG')
    disp('3. AdditiveCG')
    disp('4. RVGED')
    disp('5. RVGUD')
    get_randomizer = input('The randomizer generator use is(1 ~ 5): ');
    
    interarrival_time_number       = 8;
    SERVICE_TIMES_NUMBER           = 5;
    NUM_OF_ITEM_TIMES              = 9;
    SERVICE_TIME_DEFAULT_BUMP      = 2; %set the default service time as 2
    ITEM_TIME_DEFAULT_BUMP         = 0;	%set the default service time as 0
    INTERARRIVAL_TIME_DEFAULT_BUMP = 0;	%set the default service time as 0
    SERVICE_TIME_RN_SIZE           = 100;
    INTERARRIVAL_TIME_RN_SIZE      = 100;
    ITEM_RN_SIZE                   = 100;
    ITEM_NUMBER_RN_SIZE            = 3;
    
    % Will be generated before the main loop
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

    %------------------------------------------------------------------------------------------------------------------------------------------------------
    %user select the generator 
    %return error message if user enter wrongly 
    %Remind user to pass in correct arguments
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
        randomizer = 'LinearCG';
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
	
    
    %------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
     %this is to generate service time 
     %Generate counters' profiles - their minimum service time, probability of each service time
    
    counter_service_times =  serviceTime(counter_selected,randomizer,counter_service_times);

    %------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % Generate Interarrival Times, for-loop used only to indent the code
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

    % Generate Interarrival Table
    fprintf('INTERARRIVAL TABLE\n')
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
        fprintf('\t\t\t%d\t\t\t\t\t\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t%3d - %3d\n',[i probability(i) interarrival_time_random_range(i) randno_range_start(i) randno_range_end(i)])
    end
    disp('|==================================================|')
    fprintf('\n\n\n')
    
    %-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %this is to generate item number
    
    for i = 1:1;

        % First we generate list of numbers ranging from 1 - 100
        item_candidates = [];
        
        
        for j = 1:NUM_OF_ITEM_TIMES;
            item_candidates(j) = feval(randomizer, 1, 1, ITEM_RN_SIZE)(1);
        end
    
        %========================================
        % Find the denominator for the candidate numbers to divide against
        item_candidates_sum = sum(item_candidates);

        % Now make them random number range of 1 - 100
        item_random_range = [];

        for j = 1:NUM_OF_ITEM_TIMES;
            item_random_range(j) = round(100 * item_candidates(j) / item_candidates_sum);

            if (j >= 2);
                item_random_range(j) = item_random_range(j) + item_random_range(j - 1);
            end
        end

        % Sometimes the range max may not end at 100, therefore to solve the issue:
        item_random_range = item_random_range + (100 - item_random_range(NUM_OF_ITEM_TIMES));
        % Acquire random no range lower limit 
        randno_range_start=[];
        %Random no range always start with 1 ( 1 - *)
        randno_range_start(1)=1;
        %===========================================
        for j = 1:NUM_OF_ITEM_TIMES;

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
    fprintf('ITEM TABLE\n')
    disp('|=============================================================|')
    disp('|Item         | Probability | CDF    | Random No   | Price    |')
    disp('|Number       |             | F(X)   | Range       |          |')
    disp('|=============================================================|')
    
    item_random_range=item_random_range/100;
    item_random_range=item_random_range';
    
    probability=[];
    probability(1)=item_random_range(1);
    for i =1:NUM_OF_ITEM_TIMES-1;
        j=i+1;
        probability(j)=item_random_range(j)-item_random_range(i);
    end

    
    randno_range_end=[];
    
    randno_range_end(NUM_OF_ITEM_TIMES)=100;
    for i = 1:(NUM_OF_ITEM_TIMES-1)
        j=i+1;
        randno_range_end(i)=randno_range_start(j)-1;
    end
    
    item_random_price=[];
    for j = 1:NUM_OF_ITEM_TIMES;
        item_random_price(j) = feval(randomizer, 1, 1, ITEM_RN_SIZE)(1);
    end
    
    
    
    for i = 1:NUM_OF_ITEM_TIMES;
        fprintf('\t\t\t%d\t\t\t\t\t\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t\t\t\t\t\t%2.2f\t\t\t\t%3d - %3d\t\t\t\t%2.2f\n',[i probability(i) item_random_range(i) randno_range_start(i) randno_range_end(i) item_random_price(i)])
    end
    disp('|=============================================================|')
    fprintf('\n\n\n')
    
    
    %-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
     % Let's simulate all the customers arriving
    disp('|====================================================================================| ')
    disp('|Cust | Interarrival | Arrival | Items     | RN for the  | Item    | Total           | ')
    disp('|ID   | Time         | Time    | Purchased | item number | number  | price           | ')
    disp('|====================================================================================| ')

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
        fprintf('\t\t\t%3d \t\t\t\t\t\t %3d \t\t\t\t\t\t %3d \t\t\t\t %3d \t\t\t\t %3d \t\t\t\t\t\t\t\t\t %3d \t\t\t\t\t\t %3d\n', [customer customer_interarrival_times(customer) customer_arrival_times(customer) item_purchased(customer) item_random_number(customer) item_random_number(customer) customer_total_price(customer) ])

    end;
    
    disp('|======================================================================================| ')
    fprintf('\n\n\n')
    %----------------------------------------------------------------------------------------------------------------------------------------------------
    % Let's simulate all the customers arriving
    disp('|===========================================================================================|')
    disp('|Cust | Interarrival | Arrival | Queued | Counter | Service | Service  | Service | Total     |')
    disp('|ID   | Time         | Time    | Time   | Number | Starts  | Duration | Ends    | Time Spent|')
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
        fprintf('\t\t\t%3d \t\t\t\t\t\t %3d \t\t\t\t\t\t %3d \t\t\t\t %3d \t\t\t\t %3d \t\t\t\t\t\t %3d \t\t\t\t\t %3d \t\t\t\t\t %3d \t\t\t\t\t\t\t %3d\n', [customer customer_interarrival_times(customer) customer_arrival_times(customer) customer_queued_times(customer) customer_served_by(customer) customer_service_begin_times(customer) customer_service_duration(customer) customer_service_end_times(customer) customer_total_spent_times(customer)])

    end;
    disp('|===========================================================================================|')
    
    
    %Timeline
    fprintf('\n\n\n');
    disp('|===========================================================================================|')
    disp('|                               DISCRIPTION OF CUSTOMERS                                    |')
    disp('|===========================================================================================|')
    fprintf('\n\n');
    for customer = 1:number_of_customers;
        fprintf('Customer %d arrives at minute %d and queues at Counter %d\n',customer,customer_arrival_times(customer),customer_served_by(customer));
        fprintf('Service Time is %d and Service starts at %d\n',customer_service_duration(customer),customer_service_begin_times(customer));
        fprintf('Customer %d departs at %d\n\n',customer,customer_service_end_times(customer));
    end
    
    disp('|===========================================================================================|')
    %-------------------------------------------------------------------------------------------------------------------------------------------------------
    fprintf('\n\n')
    disp('|========================================|')
    fprintf('| SUMMARY OF THE COUNTERS                 |\n');
    disp('|========================================|')
    % Testing
    fprintf('\n\n');
    %Initialize counter_busy array
    counter_busy=[]; 
    for counter = 1:counter_selected;
        fprintf('Counter %d spent total of %d minutes serving total of %d customers.\n', [counter counter_spent_times(counter) counter_number_of_customers(counter)]);
        counter_busy(counter)=(counter_spent_times(counter)/customer_service_end_times(number_of_customers))* 100;
        fprintf('Percentage of Counter %d being busy is %2.2f percent.\n\n',counter,counter_busy(counter))
    end

    fprintf('\n');
    %----------------------------------------------------------------------------------------------------------------------------------------------------
    % Avergae customer waiting time + Chance of them queueing up
    customer_avg_queue_time = mean(customer_queued_times);
    percentage_of_customers_queue_up = 100 * length(nonzeros(customer_queued_times)) / number_of_customers;
    disp('|========================================|')
    fprintf('| SUMMARY OF THE CUSTOMER SERVICE SYSTEM |\n');
    disp('|========================================|')
    fprintf('\n\n')
    fprintf('%3.2f percent of customers have spent time queueing up\n', [percentage_of_customers_queue_up]);
    fprintf('Average waiting time: %5.2f\n', [customer_avg_queue_time])

    % Average service time
    customer_avg_service_time = mean(customer_service_duration);
    customer_avg_interarrival_time = mean(customer_interarrival_times);
    customer_avg_spent_time = mean(customer_total_spent_times);

    fprintf('Average service time of each counter: %5.2f\nAverage interarrival time: %5.2f\nAverage time customer spent in Customer Service System: %5.2f\n\n\n', [customer_avg_service_time customer_avg_interarrival_time customer_avg_spent_time]);

	
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