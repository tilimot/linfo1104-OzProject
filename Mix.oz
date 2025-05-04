% Auteurs: 
% Moers Simon - 97272400
% Butenda Babapu Timothée

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

%%%%%%%%%%%%%%%%%%%%%%%
% FONCTIONS UTILITAIRES
%%%%%%%%%%%%%%%%%%%%%%%

   %x tous les échantillons par
   fun {ScaleSample Factor Samples}
      case Samples of
         nil then nil
      [] H|T then (H*Factor) | {ScaleSample Factor T}
      end
   end

   %add 2 listes d'échantillons
   fun {AddSample L1 L2}
      case L1#L2 of
         nil#nil then nil
      [] (H1|T1)#nil then H1 | {AddSample T1 nil}
      [] nil#(H2|T2) then H2 | {AddSample nil T2}
      [] (H1|T1)#(H2|T2) then (H1+H2) | {AddSample T1 T2}
      end
   end

   %entre -1.0 et 1.0
   fun {Limit X}
      if X > 1.0 then
         1.0
      elseif X < ~1.0 then
         ~1.0
      else
         X
      end
   end

   fun {LimitList Sample}
      case Sample of nil then 
         nil
      [] H|T then
         {LimitList H} | {LimitList T}
      else
         {Limit Sample}
      end
   end   

   fun {Take L N}
      if N =< 0 orelse L == nil then
         nil
      else
         case L of H|T then
            H | {Take T N-1}
         end
      end
   end   


%%%%%%%%%%%%%%%%%%%%%%%
% FILTRES
%%%%%%%%%%%%%%%%%%%%%%%

   %Repeat -> répéter musique amount fois
   fun {Repeat amount Music}
      if amount =< 0 then
         nil
      else
         {List.append Music {Repeat amount-1 Music}}
      end
   end

   %Loop -> répéter une musique jusqu'à une durée
   fun {Loop duration Music}
      Total = {FloatToInt duration * 44100.0}
      fun {LoopCreate Acc}
         Length = {Length Acc}
      in
         if Length >= Total then
            % coupe
            {Take Acc Total}
         else
            % ajout ala fin de Acc
            {LoopCreate {List.append Acc Music}}
         end
      end
   in
      {LoopCreate nil}
   end

   %Clip -> echant. entre low/high
   fun {Clip Low High Music}
      case Music of
         nil then 
            nil
      [] H|T then
         C = 
            if H < low then 
               Low
            elseif H > high then 
               High
            else 
               H
            end
      in
         C | {Clip Low High T}
      end
   end

   %echo
   fun {Echo delay decay repeat music}
      fun {EchoCreate I}
         if I > repeat then nil
         else
            DelaySamples = {FloatToInt delay * 44100.0}
            Scaled = {ScaleSample {Pow decay I} music}
            Delayed = {List.append {SilenceSample delay} Scaled}
         in
            Delayed | {EchoCreate I+1}
         end
      end
      EchoList = {EchoCreate 1}
   in
      {FoldL EchoList music AddSample}
   end
   


         

%%%%%%%%%%%%%%%%%%%%%%%
% FONCTIONS
%%%%%%%%%%%%%%%%%%%%%%%
   % Liste samples pour une note
   fun {NoteSample Note}
      case Note of
         note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:_ ) then
            %conversion note -> octave
            NoteBase =
               case Name
               of a then 0.0 [] b then 2.0 [] c then ~9.0
               [] d then ~7.0 [] e then ~5.0 [] f then ~4.0 [] g then ~2.0
               end
            
            %#
            SharpAdjust = if Sharp then 1.0 else 0.0 end
            
            %octave
            OctaveAdjust = (Octave - 4) * 12
            
            %
            H = NoteBase + SharpAdjust + {IntToFloat OctaveAdjust}
   
            %conversion
            Freq = {Pow 2.0 H/12.0} * 440.0
   
            %param
            SampleRate = 44100.0
            NSamples = {FloatToInt Duration * SampleRate}
            Pi = 3.141592653589793
   
            %créerr echant.
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
      case Part of nil then
            nil
         [] H|T then 
            {List.append {PartitionSample H} {PartitionSample T}} 
         []note(...) then 
            {NoteSample Part}
         [] silence(duration:_) then
            {SilenceSample Part}
      end
   end

   
   fun {MergeSample P2T Musics}
      case Musics of
         nil then
            nil
      [] (Factor#Music)|Rest then
         Mix1 = {Mix P2T Music}
         MixRest = {MergeSample P2T Rest}

         ScaledMix1 = {ScaleSample Factor Mix1}
      in
         {AddSample ScaledMix1 MixRest}
      end
   end

   fun {MixAux P2T Music}
      case Music of nil then
         nil
      [] H|T then {MixAux P2T H}|{MixAux P2T T}

      []samples(S) then
                  Music
      [] partition(P) then
            {MixAux P2T samples({PartitionSample {P2T P}})}
            
      [] wave(Song) then
         try
            {Project2025.load CWD#Song}
         catch _ then
            {System.showInfo "Introuvable: "#Song}
            nil
         end
      [] merge(Music) then
            {MergeSample P2T Music}
      [] repeat(amount:A music:M) then
            {Repeat A {MixAux P2T M}}
      [] loop(duration:D music:M) then
            {Loop D {MixAux P2T M}}
      [] clip(low:L high:H music:M) then
            {Clip L H {MixAux P2T M}}
      [] echo(delay:D decay:F repeat:R music:M) then
            {Echo D F R {MixAux P2T M}}
      % [] fade(start:S finish:F music:M) then
      %       nil
      % [] cut(start:S finish:F music:M) then
      %       nmerge(〈musicsil
      end
   end 

   



   %Mix
   fun {Mix P2T Music}
         Samples = {MixAux P2T Music}.1
      in 
         Samples.1      
   end
   
   
end