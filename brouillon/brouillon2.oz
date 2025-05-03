declare 
B = [note(a) note(b) [note(c) note(d)]]
fun {CreateChords L}
    case L of nil then nil
    [] H|T then
        if {IsList H} then chord(H)|{CreateChords T}
        else
            H|{CreateChords T}
        end
    end
end


fun {Transpose A}
    case A of nil then nil
    [] H|T then {Transpose H}| {Transpose T}
    [] note(...) then note(h)
    [] chord(...) then chord(j)
    end
end

{Browse {Tanspose {CreateChords B}}}