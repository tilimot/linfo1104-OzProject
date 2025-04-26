declare 

fun {ReadPartition Partition NoteDuration}
    case Partition of nil then nil
    [] H|T then 
        case H of note(...) then note(name:H.name duration:NoteDuration)|{ReadPartition T NoteDuration}
        [] transform(...) then {HandleTransform H}|{ReadPartition T NoteDuration}
        else
            H|{ReadPartition T NoteDuration}
        end
    end
end


fun {HandleTransform T}
    {ReadPartition T.1 T.duration}
end

fun {HandleStretch S}


P1 = [note(name:a duration:3) note(name:a duration:4)]
P2 = [note(name:c duration:7) note(name:f duration:8) transform(duration:1 P1) note(name:d duration:9)]

P3= [1 2 3]

{Browse {ReadPartition P2 10}}

