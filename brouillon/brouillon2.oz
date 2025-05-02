functor
import
    System 
define
    local Limit in 
        fun {Fade F}
            % F is fade(...)

            % For Start fade
            if {Value.hasFeature F start} then 
                Limit = {FloatToInt F.start * 44100.0}
                {System.show 'here'}
                {HandleFadeStart F.1 Limit 1 1}
                {System.show 'here3'}
            end

            % for finish fade
            if ({Value.hasFeature F finish}) then
            {System.show 'to complete'}
            end
        end
    end

  
    fun {HandleFadeStart Music Limit Acc} % Limit is NumSampletoFade
        {System.show Music}
        {System.show Limit}
        {System.show Acc}
        case Music of nil then nil
        [] H|T then
            if ( Acc > Limit) then
                Music 
            else
                {System.show 'here4'}
                Result = {IntToFloat H} * ({IntToFloat Acc}/{IntToFloat Limit})
            in
                Result | {HandleFadeStart T Limit Acc+1}
            end
        end
    end

    %%% test %%%
    F=fade(start:0.000226757  [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 ])
    {System.show {Fade F}}


end


/* 
Length = {List.Length F.1} % l'Invoquer direct dans l'appel de fonction
NumSampleToFade = Fade.start * 44100 % The number of sample to modify with Feature --> 44100 sample/sec sor for 3.1 sec we have 3.1*44100 samples to modify
in
    if (Length >= NumSampleToFade) then 
        {handleFadeStart F.1 0} %Need Check if Length >= NumSampleToFade
    else
        {System.show 'Error'}
    end
*/