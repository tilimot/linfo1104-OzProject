declare
TOT_DUR
DURATION = {NewCell 1.0}
OCTAVE = {NewCell 4}


% Translate a note to the extended notation.
fun {NoteToExtended Note}
    case Note
    of nil then nil 
    [] note(name octave sharp duration instrument) then note(name:namt octave:octave sharp:true duration:duration instrument:none)
    [] silence(duration: _) then silence(duration: 17.0)
    [] silence then silence(duration:1.0)
    [] Name#Octave then note(name:Name octave:Octave sharp:true duration:@DURATION instrument:none)
    [] Atom then
        case {AtomToString Atom}
        of [_] then
            note(name:Atom octave:@OCTAVE sharp:false duration:@DURATION instrument:none)
        [] [N O] then
            note(name:{StringToAtom [N]}
                octave:{StringToInt [O]}
                sharp:false
                duration:@DURATION
                instrument: none)
        end
    end
end

% Translate Chord into Extended notation
fun {ChordToExtended Chord}
    case Chord of H|T then 
        case H of C|N then {ChordToExtended H}|{ChordToExtended T}
        else
            {NoteToExtended H}|{ChordToExtended T}
        end
    else
        Chord
    end
end



fun {PartitionToExtended P}
    % we could in theory call 1 thread for ChordExtension and 1 for Note extension. Theory --> bc of oz dataflow, can wait if value is required.
    case P of nil then nil
    [] H|T then 
        case H of C|N then {ChordToExtended H}|{PartitionToExtended T}
        else
            {NoteToExtended H}| {PartitionToExtended T}
        end
    end
end


Tune = [b b c5 d5 [[d5 c5] [b a] g] g a b]

P = {PartitionToExtended Tune}
{Browse  P}