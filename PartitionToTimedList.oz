 
 functor
 import
    Project2025
    System
    Property
 export 
    partitionToTimedList: PartitionToTimedList
 define
 
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
            case H of C|N then {ChordToExtended C}|{ChordToExtended N}
            else
                {NoteToExtended H}|{ChordToExtended T}
            end
        else
            Chord
        end
    end
                
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    fun {PartitionToTimedList Partition}
        % TODO
        nil
    end

    fun {ReadPartition P}
        case P of nil then nil
        [] H|T then 
            case H of C|N then {ChordToExtended C}|{ReadPartition N}
            else
                {NoteToExtended H}| {ReadPartition T}
            end
        end
    end

end