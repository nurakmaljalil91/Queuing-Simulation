function y = linearCongruentialGenerator(n, prev, max) %Linear Congruential Generator
    
    a = 4;
    c = 29;
    x = rand()*max;
    %the usage of ceil is to make value into a whole number
    x = ceil(x);
    % x is a random number set as Xn-1
    
    % FORMULA of LCG
    % Xn=((a*prev)+c)(mod m)
    
    for i=1:n
        
        z = a*x + c;
        y(i) = (ceil(mod(z, max)));
        
        %result is inserted into y(i)
        if y(i) < max-prev;
            y(i) = y(i) + prev;
        end
        
        x = y(i);
    end