declare
/*Extend each note */
% Translate a note to the extended notation.
fun {NoteToExtended Note}
    case Note
    of nil then nil 
    [] note(...) then Note
    [] silence(duration: _) then Note
    [] silence then silence(duration:1.0)
    [] Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
    [] Atom then
        case {AtomToString Atom}
        of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
        [] [N O] then
            note(name:{StringToAtom [N]}
                octave:{StringToInt [O]}
                sharp:false
                duration:1.0
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
    case P of nil then nil
    [] H|T then 
        case H of C|N then {ChordToExtended H}|{PartitionToExtended T}
        [] stretch(...) then stretch(factor:H.factor {PartitionToExtended H.1})|{PartitionToExtended T}
        else
            {NoteToExtended H}| {PartitionToExtended T}
        end
    end
end


Tune = [b b c5 d5 d5 c5 b a g g a b]
End1 = [stretch(factor:1.5 [b]) stretch(factor:0.5 [a]) stretch(factor:2.0 [a])]
End2 = [stretch(factor:1.5 [a]) stretch(factor:0.5 [g]) stretch(factor:2.0 [g])]
Interlude = [a a b g a stretch(factor:0.5 [b c5])
                b g a stretch(factor:0.5 [b c5])
            b a g a stretch(factor:2.0 [d]) ]

% This is not a music.
Partition = [Tune End1 Tune End2 Interlude Tune End2]
{Browse {PartitionToExtended [End1]}}