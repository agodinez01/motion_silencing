function [outputArg1] = convertMonth2Number(inputArg1)
% Converts month to number
% Angelica Godinez 2022

if inputArg1(4:6) == 'Jan'
    outputArg1 = '01';

elseif inputArg1(4:6) == 'Feb'
    outputArg1 = '02';

elseif inputArg1(4:6) == 'Mar'
    outputArg1 = '03';

elseif inputArg1(4:6) == 'Apr'
    outputArg1 = '04';

elseif inputArg1(4:6) == 'May'
    outputArg1 = '05';

elseif inputArg1(4:6) == 'Jun'
    outputArg1 = '06';

elseif inputArg1(4:6) == 'Jul'
    outputArg1 = '07';

elseif inputArg1(4:6) == 'Aug'
    outputArg1 = '08';

elseif inputArg1(4:6) == 'Sep'
    outputArg1 = '09';

elseif inputArg1(4:6) == 'Oct'
    outputArg1 = '10';

elseif inputArg1(4:6) == 'Nov'
    outputArg1 = '11';

elseif inputArg1(4:6) == 'Dec'
    outputArg1 = '12';

end

end