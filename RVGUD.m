function y = RVGUD(n, prev, max) %Random Uniform Distribution 

    %FORMULA of RVGUD
    %X = a + (b - a)R
    x = rand(1, n);
    
    z = prev + (max-prev)*x;
    
    %the usage of ceil is to make value into a whole number
    y = ceil(z);
    
    end