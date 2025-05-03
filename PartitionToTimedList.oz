functor
import
Project2025
System
Property
export 
partitionToTimedList: PartitionToTimedList
define

    %%%%%%%%%%%%%%%%%%%%%%%% Extend Partition %%%%%%%%%%%%%%%%%%%%%%%%
    /*Funcs to transform each note into extended note */

    % Extend each note without transformation
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

    % Extend Chords and store it into a record
    fun {ChordToExtended Chord}
        chord({Map Chord NoteToExtended})
    end
  


    % Run trough the given Partition and transform each notes into extended note
    fun {PartitionToExtended P}
        case P of
           nil then nil
        [] H|T then 
            if {IsList H} then 
                {ChordToExtended H} | {PartitionToExtended T}
            else 
                {PartitionToExtended H} | {PartitionToExtended T}
            end
        [] stretch(...) then stretch(factor:P.factor {PartitionToExtended P.1})
        [] duration(...) then duration(seconds:P.seconds {PartitionToExtended P.1})
        [] drone(...) then drone(note:{PartitionToExtended P.note} amount:P.amount)
        [] mute(...) then {PartitionToExtended drone(note:silence amount:P.amount)}
        [] transpose(...) then transpose(semitones:P.semitones {PartitionToExtended P.1})
        else
            {NoteToExtended P}
        end
    end
    
     


    %%%%%%%%%%%%%%%%%%%%%%%% Apply transforms %%%%%%%%%%%%%%%%%%%%%%%%

    /* Call corresponding func to transform required */
    fun {ApplyTransform P}
        case P of
           nil then nil
        [] H|T then {ApplyTransform H} | {ApplyTransform T}
        [] stretch(...) then {HandleStretch P}
        [] drone(...) then {HandleDrone P}
        [] duration(...) then {HandleDuration P}
        [] transpose(...) then {HandleTranspose P}
        [] note(...) then P
        [] silence(...) then P
        else
           if {IsList P} then
              {Map P ApplyTransform}
           else
              P
           end
        end
     end
     


    /***************** Stretch Transform ***************** 
        Return a list of stretched extended note
        */

    fun{HandleStretch P}
        {Stretch P.1 P.factor}
    end
        
    fun{Stretch P F}
        case P of nil then nil
        [] H|T then {Stretch H F}|{Stretch T F}
        [] note(...) then note(name:P.name octave:P.octave sharp:P.sharp duration:P.duration*F instrument:none)
        [] silence(...) then silence(duration:P.duration*F)
        else
            {Stretch {ApplyTransform P} F} % Risk of StackOverflow. Maybe prefer to returns directly the element P
        end
    end


    /*****************  Drone Transform ***************** 
        Return a list of droned extended note 
    */

    fun{HandleDrone D}
        {HandleDroneAux D.note D.amount 0}
    end


    fun{HandleDroneAux Note Amount Acc}
        if Acc==Amount then nil
        else
            Note|{HandleDroneAux Note Amount Acc+1}
        end
    end


    /*****************  Duration transform ***************** 
        Return a transposed Partition
    */

    fun{HandleDuration D}
        %Partition -> D.1
        %Factor-> ExpectedTime/CurrentTime
        {Stretch D.1 D.seconds/{CurrentTotalTime D.1 0.0}}
    end


    fun{CurrentTotalTime P Acc}
        case P of nil then Acc                                                          %          _         _ 
        [] H|T then {CurrentTotalTime T Acc+{CurrentTotalTime H 0.0}} % not so recursive terminale  \_(°-°)_/
        [] note(...) then Acc+P.duration
        [] silence(...) then Acc+P.duration
        else
            Acc+{CurrentTotalTime {ApplyTransform P} 0.0}                                                            
        end
    end    

    /***************** Chord transform *****************
    */
    fun {HandleChord Chord}
        case Chord of
            nil then nil
        [] H|T then
            {NoteToExtended H} | {HandleChord T}
        end
    end


    /***************** Transposition transform *****************
    */

    fun{HandleTranspose T}
        {Transpose T.semitones T.1 }
    end

    fun{Transpose Semitones Note}
        case Note of nil then nil 
        [] H|T then {Transpose Semitones H} | {Transpose Semitones T}
        [] silence(...) then Note
        [] note(...) then {TransposeNote Semitones Note}
        else
            {Transpose Semitones {ApplyTransform Note}}
        end
    end

    NoteToPos = noteIndex(c:0 d:2 e:4 f:5 g:7 a:9 b:11)
    PosToNote = indexNote(
        0:note(name:c sharp:false)
        1:note(name:c sharp:true)
        2:note(name:d sharp:false)
        3:note(name:d sharp:true)
        4:note(name:e sharp:false)
        5:note(name:f sharp:false)
        6:note(name:f sharp:true)
        7:note(name:g sharp:false)
        8:note(name:g sharp:true)
        9:note(name:a sharp:false)
        10:note(name:a sharp:true)
        11:note(name:b sharp:false)
    )

    fun {TransposeNote Semitones Note}
        local
            Index = if Note.sharp == true then
                        Index = NoteToPos.(Note.name)+1
                    else
                        Index = NoteToPos.(Note.name)
                    end
            
            NewIndex = (Index + Semitones) mod 12
            NewOctave = Note.octave + ((Index + Semitones) div 12)
            NewName = PosToNote.NewIndex.name
            Sharp = PosToNote.NewIndex.sharp
        in 
            note(name:NewName octave:NewOctave sharp:Sharp duration:Note.duration instrument:Note.instrument)
        end
    end


    /*
    local Index NewIndex NewOctave NewName Sharp NoteToPos PosToNote in
        fun {TransposeNote Semitones Note}
            
            NoteToPos = noteIndex(c:0 d:2 e:4 f:5 g:7 a:9 b:11)
            PosToNote = indexNote(
                0:note(name:c sharp:false)
                1:note(name:c sharp:true)
                2:note(name:d sharp:false)
                3:note(name:d sharp:true)
                4:note(name:e sharp:false)
                5:note(name:f sharp:false)
                6:note(name:f sharp:true)
                7:note(name:g sharp:false)
                8:note(name:g sharp:true)
                9:note(name:a sharp:false)
                10:note(name:a sharp:true)
                11:note(name:b sharp:false)
            )
            
            Index = if Note.sharp == true then
                        Index = NoteToPos.(Note.name)+1
                    else
                        Index = NoteToPos.(Note.name)
                    end
            
            NewIndex = (Index + Semitones) mod 12
            NewOctave = Note.octave + ((Index + Semitones) div 12)
            NewName = PosToNote.NewIndex.name
            Sharp = PosToNote.NewIndex.sharp
            note(name:NewName octave:NewOctave sharp:Sharp duration:Note.duration instrument:Note.instrument)
        end
    end
    */


    %%%%%%%%%%%%%%%%%%%%%%%% PartionToTimeList %%%%%%%%%%%%%%%%%%%%%%%%

    fun {PartitionToTimedList Partition}

        %{Flatten {ApplyTransform {PartitionToExtended Partition}}}
        {ApplyTransform {PartitionToExtended Partition}}
    end


end