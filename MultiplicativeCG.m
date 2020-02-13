function y = MultiplicativeCG(n, prev, max) %Multiplicative Congruential Generator
    
    %FORMULA of MCG
    %c=0,Xn=((a*prev)+0)(mod m)    
    a = 4;
    x = rand()*max;
     %the usage of ceil is to make value into a whole number
    x = ceil(x);
    
    for i=1:n
        
        z = a*x;
        y(i) = (ceil(mod(z, max)));
        
        if y(i) < max-prev;
            y(i) = y(i) + prev;
        end
        
        x = y(i);
    end