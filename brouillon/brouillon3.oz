functor
import
    System 
define
    fun{HandleTranspose T}
        {Transpose T.semitones T.1 }
        
    end

    fun{Transpose Semitones Note}
        case Note of nil then nil 
        [] H|T then {Transpose Semitones H} | {Transpose Semitones T}
        [] silence(...) then Note
        [] note(...) then {TransposeNote Semitones Note}
        end
    end

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
            {System.show Index}
            {System.show NewIndex}
            NewOctave = Note.octave + ((Index + Semitones) div 12)
            NewName = PosToNote.NewIndex.name
            Sharp = PosToNote.NewIndex.sharp
            note(name:NewName octave:NewOctave sharp:Sharp duration:Note.duration instrument:Note.instrument)
        end
    end

    L = transpose(semitones:2 note(name:a octave:4 sharp:true duration:1.0 instrument:none))
    {System.show {HandleTranspose L}}
end

