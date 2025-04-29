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


    % Run trough the given Partition and transform each notes into extended note
    fun{PartitionToExtended P}
        case P of nil then nil
        [] H|T then {PartitionToExtended H}| {PartitionToExtended T}
        []stretch(...) then stretch(factor:P.factor {PartitionToExtended P.1})
        []duration(...) then duration(seconds:P.seconds {PartitionToExtended P.1})
        []drone(...) then drone(note:{PartitionToExtended P.note} amount:P.amount)
        []mute(...) then {PartitionToExtended drone(note:silence amount:P.amount)} % Mute direclty handled --> Transform mute into drone with extended notes
        []transpose(...) then transpose(semitones:P.semitones {PartitionToExtended P.1})
        else
            {NoteToExtended P}
        end
    end 


    %%%%%%%%%%%%%%%%%%%%%%%% Apply transforms %%%%%%%%%%%%%%%%%%%%%%%%

    /* Call corresponding func to transform required */

    fun{ApplyTransform P}
        case P of nil then nil
        [] H|T then {ApplyTransform H} | {ApplyTransform T}
        [] stretch(...) then {HandleStretch P}
        [] drone(...) then {HandleDrone P}
        [] duration(...) then {HandleDuration P}
        
        else
            P
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


    local Partition CurrentTime ExpectedTime Factor  in  
        fun{HandleDuration D}
            Partition=D.1
            CurrentTime={CurrentTotalTime Partition 0.0}
            ExpectedTime=D.seconds
            Factor=ExpectedTime/CurrentTime
            {Stretch Partition Factor }
        end
    end 


    fun{CurrentTotalTime P Acc}
        case P of nil then Acc
        [] H|T then 
            case H of note(...) then {CurrentTotalTime T Acc+H.duration}
            else                                                                    %                           _         _   
                {CurrentTotalTime T Acc+{CurrentTotalTime {ApplyTransform H} 0.0}} % not so recursive terminale  \_(°-°)_/
            end
        end
    end 


    /***************** Transposition transform *****************
    */

    %%%%%%%%%%%%%%%%%%%%%%%% PartionToTimeList %%%%%%%%%%%%%%%%%%%%%%%%

    fun {PartitionToTimedList Partition}
        {Flatten {ApplyTransform {PartitionToExtended Partition}}}
    end


end