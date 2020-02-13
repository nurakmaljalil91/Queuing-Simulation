function y = ACG(n, prev, max) %Additive Congruential Generator
    
    %FORMULA of ACG
    %a=1,Xn=((1*prev)+c)(mod m)
    
    c = 29;
    x = rand()*max;
    %the usage of ceil is to make value into a whole number
    x = ceil(x);
    
    for i=1:n
        
        z = x + c;
        y(i) = (ceil(mod(z, max)));
        %save into the array y(i)
        if y(i) < max-prev;
            y(i) = y(i) + prev;
        end
        
        x = y(i);
    end