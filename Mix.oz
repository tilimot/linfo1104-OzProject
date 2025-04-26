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

   
   %Liste samples pour une note
   fun {NoteSample Note}
      case Note of
         note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:_ ) then
            %Position note 440Hz (demi-tons)
               NoteBase =
               case Name
               of a then 0.0
               [] b then 2.0
               [] c then ~9.0
               [] d then ~7.0
               [] e then ~5.0
               [] f then ~4.0
               [] g then ~2.0
               end
         %si dièse
         SharpAdjust = if Sharp then 1.0 else 0.0 end
         OctaveAdjust = (Octave - 4) * 12.0
         H = NoteBase + SharpAdjust + OctaveAdjust
   
         %fréquence
         Freq = {Pow 2.0 H/12.0} * 440.0
   
         %nbr échantillons
         SampleRate = 44100
         NSamples = {FloatToInt Duration * SampleRate}
   
         %sample
         Pi = 3.141592653589793
         fun {CreateSample I}
               if I >= NSamples then
                  nil
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
   
   fun {SilenceSample Silence}
      case Silence of
         %durée du silence
         silence(duration:Duration) then
               SampleRate = 44100
               %nbr échantilons
               NSamples = {FloatToInt Duration * SampleRate}
               
               %sample
               fun {CreateSilence I}
                  if I >= NSamples then
                     nil
                  else
                     0.0 | {CreateSilence I+1}
                  end
               end
         in
               {CreateSilence 0}
      end
   end

   %partition etendue -> liste echantillon
   fun {PartitionSample Part}
      %partition vide
      case Part of
         nil then
               nil
      [] H|T then
         case H of
         %sample de note
               note(...) then
                  {List.append {NoteSample H} {PartitionSample T}}
         %sample silence
         [] silence(duration:_) then
                  {List.append {SilenceSample H} {PartitionSample T}}
         [] _ then
                  {PartitionSample T}
         end
      end
   end

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
end