function output = SIPrefix( value,unit )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if nargin > 1
        if value >= 10^9
            output = [num2str(value/(10^9)),' G',unit];
        elseif value < 10^9 && value >= 10^6
            output = [num2str(value/(10^6)),' M',unit];
        elseif value < 10^6 && value >= 10^3
            output = [num2str(value/(10^3)),' k',unit];
        elseif value < 10^3
            output = [num2str(value),' ',unit];
    end
end

