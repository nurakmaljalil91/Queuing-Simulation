function y = RVGED(n, prev, max) %Random Exponential Distribution 
    %generate a random number
    j = rand();
    
    %mean number of occurrence per unit time.
    %this is the lambda thing
    j = mod(j*100,7);
    
    %the usage of ceil is to make value into a whole number
    j = ceil(j);
    
    a = rand(1,n);
    
    %FORMULA of RVGED
    %X = (-1/lambda)ln(1-R)
    %ln(x) represents the natural logarithm of x.
    
    z = (-1/j)*(log(1-a));
    
    x = (z * max);
    x = mod(x, max);
    
    if x < prev
        x = x + prev;
    end
    
    y = ceil(x);