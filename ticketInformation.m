function ticketInformation(randomizer)

    number_of_day = feval(randomizer,1,1,4);
    ticket_movie_1 = feval(randomizer,1,1,999)(1);
    ticket_movie_2 = feval(randomizer,1,1,999)(1);
    ticket_movie_3 = feval(randomizer,1,1,999)(1);
  
    printf('TICKET''S INFORMATION\n')
    disp('|------------------------------------------|')
    disp('| Day/     | total   | total    | total    |')
    disp('| Slot     | movie 1 | movie 2  | movie 3  |')
    disp('|------------------------------------------|')
    for i = 1:3          
        printf('|\t\t\t\t%d\t\t\t\t\t\t\t\t\t\t%d\t\t\t\t\t\t\t\t%d\t\t\t\t\t\t\t\t%d\n',i,ticket_movie_1,ticket_movie_2,ticket_movie_3)
    end
    disp('|------------------------------------------|')
    fprintf('\n\n')  

    disp('Press enter to continue......')
    pause