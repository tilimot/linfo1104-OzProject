declare

fun {Stretch P}
    case P of note(...) then note(name:P.name octave:P.octave sharp:P.sharp duration:P.duration*7.0 instrument:none)
    else P
    end
end

N = note(name:a octave:4 sharp:true duration:1.0 instrument:none)

{Browse {Stretch N}}