functor
import
   Project2025
   OS
   System
   Property
export 
   mix: Mix
define

   % Get the full path of the program
   CWD = {Atom.toString {OS.getCWD}}#"/"

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Liste samples pour une note
   fun {NoteSample Note}
      case Note of
         note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:_ ) then
            % Position de base relative à A4
            NoteBase =
               case Name
               of a then 0.0 [] b then 2.0 [] c then ~9.0
               [] d then ~7.0 [] e then ~5.0 [] f then ~4.0 [] g then ~2.0
               end
            
            % Ajustement pour dièse
            SharpAdjust = if Sharp then 1.0 else 0.0 end
            
            % Ajustement pour l'octave (attention ici Octave est un int)
            OctaveAdjust = (Octave - 4) * 12
            
            % Hauteur totale
            H = NoteBase + SharpAdjust + {IntToFloat OctaveAdjust}
   
            % Conversion hauteur en fréquence
            Freq = {Pow 2.0 H/12.0} * 440.0
   
            % Paramètres d'échantillonnage
            SampleRate = 44100.0
            NSamples = {FloatToInt Duration * SampleRate}
            Pi = 3.141592653589793
   
            % Création des samples
            fun {CreateSample I}
               if I >= NSamples then nil
               else
                  Ai = 0.5 * {Sin (2.0 * Pi * Freq * {IntToFloat I} / 44100.0)}
               in
                  Ai | {CreateSample I+1}
               end
            end
         in
            {CreateSample 0}
      end
   end
   

   % Silence -> Liste de zéros
   fun {SilenceSample Silence}
      case Silence of
         silence(duration:Duration) then
            SampleRate = 44100
            NSamples = {FloatToInt Duration * SampleRate}
            fun {CreateSilence I}
               if I >= NSamples then nil
               else 0.0 | {CreateSilence I+1} end
            end
         in
            {CreateSilence 0}
      end
   end

   % Partition étendue -> Liste d'échantillons
   fun {PartitionSample Part}
      case Part of
         nil then
            nil
      [] H|T then
         case H of
            note(...) then
               {List.append {NoteSample H} {PartitionSample T}}
         [] silence(duration:_) then
               {List.append {SilenceSample H} {PartitionSample T}}
         [] _ then
               {PartitionSample T}
         end
      end
   end

   % Mix principal
   fun {Mix P2T Music}
      case Music of
         nil then
            nil
      [] H|T then
         case H of
            samples(S) then
               {List.append S {Mix P2T T}}
         [] partition(P) then
               {List.append {PartitionSample {P2T P}} {Mix P2T T}}
         [] _ then
            {Mix P2T T}
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %TEST

   P2 = [
      note(name:c octave:4 sharp:true duration:1.0 instrument:none)
      note(name:d octave:4 sharp:true duration:1.0 instrument:none)
      note(name:e octave:4 sharp:true duration:1.0 instrument:none)
      note(name:c octave:4 sharp:true duration:1.0 instrument:none)
      note(name:c octave:4 sharp:true duration:1.0 instrument:none)
      note(name:e octave:4 sharp:true duration:1.0 instrument:none)
      note(name:e octave:4 sharp:true duration:1.0 instrument:none)
   ]

   fun {TmpP2T Partition}
      Partition
   end

   Musique = [partition(P2)]
   Sample = {Mix TmpP2T Musique}

   {System.show {Length Sample}}
   {Project2025.load Sample}

end
