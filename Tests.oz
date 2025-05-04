functor
import
   Project2025
   Mix
   System
   Property
export
   test: Test
define

   PassedTests = {Cell.new 0}
   TotalTests  = {Cell.new 0}

   FiveSamples = 0.00011337868 % Duration to have only five samples

   % Takes a list of samples, round them to 4 decimal places and multiply them by
   % 10000. Use this to compare list of samples to avoid floating-point rounding
   % errors.
   fun {Normalize Samples}
      {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
   end

   proc {Assert Cond Msg}
      TotalTests := @TotalTests + 1
      if {Not Cond} then
         {System.show Msg}
      else
         PassedTests := @PassedTests + 1
      end
   end

   proc {AssertEquals A E Msg}
      TotalTests := @TotalTests + 1
      if A \= E then
         {System.show Msg}
         {System.show actual(A)}
         {System.show expect(E)}
      else
         PassedTests := @PassedTests + 1
      end
   end

   fun {NoteToExtended Note}
      case Note
      of note(...) then
         Note
      [] silence(duration: _) then
         Note
      [] _|_ then
         {Map Note NoteToExtended}
      [] nil then
         nil
      [] silence then
         silence(duration:1.0)
      [] Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
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

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % TEST PartitionToTimedNotes

   proc {TestNotes P2T}
      P1 = [a0 b1 c#2 d#3 e silence]
      E1 = {Map P1 NoteToExtended}
   in
      {AssertEquals {P2T P1} E1 'TestNotes'}
   end

   proc {TestChords P2T}
      P1 = [[c e g] silence [a#4 d#5]]
      E1 = [
         [
            note(name:c octave:4 sharp:false duration:1.0 instrument:none)
            note(name:e octave:4 sharp:false duration:1.0 instrument:none)
            note(name:g octave:4 sharp:false duration:1.0 instrument:none)
         ]
         silence(duration:1.0)
         [
            note(name:a octave:4 sharp:true duration:1.0 instrument:none)
            note(name:d octave:5 sharp:true duration:1.0 instrument:none)
         ]
      ]
   in
      {AssertEquals {P2T P1} E1 'TestChords'}
   end
   

   proc {TestIdentity P2T}
      % test that extended notes and chord go from input to output unchanged
      P1 = [a0 [b1 c#2] d#3 e silence]
      E1 = [
         note(duration:1.0 instrument:none name:a octave:0 sharp:false) 
         [
            note(duration:1.0 instrument:none name:b octave:1 sharp:false) 
            note(duration:1.0 instrument:none name:c octave:2 sharp:true)
         ] 
         note(duration:1.0 instrument:none name:d octave:3 sharp:true) 
         note(duration:1.0 instrument:none name:e octave:4 sharp:false) 
         silence(duration:1.0)
         ]
   in
      {AssertEquals {P2T P1} E1 'TestIdentity'}
   end

   proc {TestDuration P2T}
      P1 = [ g duration(seconds:10.0 [a [b c#4] d#4 silence]) duration(seconds:1.0 [a [b c#4] d#4 silence]) f e ]
      E1 = [
            % Duration n°1: duration > initial total time 
            note(name:g octave:4 sharp:false duration:1.0 instrument:none)
            note(name:a octave:4 sharp:false duration:2.0 instrument:none) 

            [note(name:b octave:4 sharp:false duration:2.0 instrument:none) 
            note(name:c octave:4 sharp:true duration:2.0 instrument:none)]

            note(name:d octave:4 sharp:true duration:2.0 instrument:none)
            silence(duration:2.0)

            % Duration n°2: duration < initial total time
            note(name:a octave:4 sharp:false duration:0.2 instrument:none)

            [note(name:b octave:4 sharp:false duration:0.2 instrument:none) 
            note(name:c octave:4 sharp:true duration:0.2 instrument:none)]

            note(name:d octave:4 sharp:true duration:0.2 instrument:none)
            silence(duration:0.2)
            note(name:f octave:4 sharp:false duration:1.0 instrument:none)
            note(name:e octave:4 sharp:false duration:1.0 instrument:none)] 
   in
      {AssertEquals {P2T P1} E1 'TestDuration'}
   end

   proc {TestStretch P2T}
      P1 = [ g stretch(factor:2.0 [a [b c#4] d#4 silence]) stretch(factor:0.2 [a [b c#4] d#4 silence]) stretch(factor:3.0 [stretch(factor:2.0 [a c#4 silence])])f e ]

      E1 = [
            note(name:g octave:4 sharp:false duration:1.0 instrument:none)

            % Stretch n°1 : factor > 1
            note(name:a octave:4 sharp:false duration:2.0 instrument:none) 
            
            [note(name:b octave:4 sharp:false duration:2.0 instrument:none) 
            note(name:c octave:4 sharp:true duration:2.0 instrument:none)]

            note(name:d octave:4 sharp:true duration:2.0 instrument:none)
            silence(duration:2.0)

            % Stretch n°2: factor < 1
            note(name:a octave:4 sharp:false duration:0.2 instrument:none) 

            [note(name:b octave:4 sharp:false duration:0.2 instrument:none) 
            note(name:c octave:4 sharp:true duration:0.2 instrument:none)]

            note(name:d octave:4 sharp:true duration:0.2 instrument:none)
            silence(duration:0.2)

            % Stretch n°3: nested stretch
            note(name:a octave:4 sharp:false duration:6.0 instrument:none) 
            note(name:c octave:4 sharp:true duration:6.0 instrument:none)
            silence(duration:6.0)
            note(name:f octave:4 sharp:false duration:1.0 instrument:none)
            note(name:e octave:4 sharp:false duration:1.0 instrument:none)] 
   in
      {AssertEquals {P2T P1} E1 'TestStretch'}
   end

   proc {TestDrone P2T}
      P1 = [ drone(note:c amount:3) f a drone(note:[c e g] amount:2) c]
      E1 = [
         % Repetition 1: note
         note(name:c octave:4 sharp:false duration:1.0 instrument:none)
         note(name:c octave:4 sharp:false duration:1.0 instrument:none) 
         note(name:c octave:4 sharp:false duration:1.0 instrument:none)

         
         note(name:f octave:4 sharp:false duration:1.0 instrument:none) 
         note(name:a octave:4 sharp:false duration:1.0 instrument:none) 
         
         % Repetition 2: chords
         [
            note(duration:1.0 instrument:none name:c octave:4 sharp:false) 
            note(duration:1.0 instrument:none name:e octave:4 sharp:false) 
            note(duration:1.0 instrument:none name:g octave:4 sharp:false)
         ] 
         
         [
            note(duration:1.0 instrument:none name:c octave:4 sharp:false) 
            note(duration:1.0 instrument:none name:e octave:4 sharp:false) 
            note(duration:1.0 instrument:none name:g octave:4 sharp:false)
         ] 
         
         note(duration:1.0 instrument:none name:c octave:4 sharp:false)
      ]
   in
      {AssertEquals {P2T P1} E1 'TestDrone'}
   end

   proc {TestMute P2T}
      P1 = [ c mute(amount:3) a mute(amount:1) c]
      E1 = [
         note(name:c octave:4 sharp:false duration:1.0 instrument:none)

         %Mute n°1
         silence(duration:1.0)
         silence(duration:1.0)
         silence(duration:1.0)

         note(name:a octave:4 sharp:false duration:1.0 instrument:none)

         % Mute n°2
         silence(duration:1.0)
         
         note(name:c octave:4 sharp:false duration:1.0 instrument:none)
      ] 
   in 
      {AssertEquals {P2T P1} E1 'TestMute'}
   end

   proc {TestTranspose P2T}
      P1 = [transpose(semitones:15 [b c#5 d9]) transpose(semitones:0 [b c#5 d9]) transpose(semitones:4 [b [d9 a g] c#5])]
      E1 = [
      % Transpose n°1: transpose > 11
      note(duration:1.0 instrument:none name:d octave:6 sharp:false) 
      note(duration:1.0 instrument:none name:e octave:6 sharp:false) 
      note(duration:1.0 instrument:none name:f octave:10 sharp:false)
      
      % Transpose n°2: transpose = 0
      note(duration:1.0 instrument:none name:b octave:4 sharp:false)
      note(duration:1.0 instrument:none name:c octave:5 sharp:true)
      note(duration:1.0 instrument:none name:d octave:9 sharp:false)

      % Transpose n°3: with chords
      note(duration:1.0 instrument:none name:d octave:5 sharp:true)

      [note(duration:1.0 instrument:none name:f octave:9 sharp:true) 
      note(duration:1.0 instrument:none name:c octave:5 sharp:true) 
      note(duration:1.0 instrument:none name:b octave:4 sharp:false)] 
      
      note(duration:1.0 instrument:none name:f octave:5 sharp:false)
      ]
   in 
      {AssertEquals {P2T P1} E1 'TestTranspose'}
   end

   proc {TestP2TChaining P2T}
      P1 = [
         transpose(semitones:3 [
            stretch(factor:2.0 [
               duration(seconds:5.0 
                  [drone(note:a amount:2) b silence [c d] mute(amount:2)]
               )]
            )]
         )
      ]

      E1 = [
         note(duration:1.25 instrument:none name:c octave:5 sharp:false) 
         note(duration:1.25 instrument:none name:c octave:5 sharp:false) 

         note(duration:1.25 instrument:none name:d octave:5 sharp:false) 

         silence(duration:1.25) 
         [
            note(duration:1.25 instrument:none name:d octave:4 sharp:true) 
            note(duration:1.25 instrument:none name:f octave:4 sharp:false)
            ]

         silence(duration:1.25) 
         silence(duration:1.25)
         ]
   in 
      {AssertEquals {P2T P1} E1 'TestP2TChaining'}
   end

   proc {TestEmptyChords P2T}
     P1 = [a b [c d] e [nil]]
     E1 = [
      note(name:a octave:4 sharp:false duration:1.0 instrument:none)
      note(name:b octave:4 sharp:false duration:1.0 instrument:none)

      [note(name:c octave:4 sharp:false duration:1.0 instrument:none)
      note(name:d octave:4 sharp:false duration:1.0 instrument:none)]

      note(name:e octave:4 sharp:false duration:1.0 instrument:none)

      % Empty chords representation
      silence(duration:0.0)
      ]
   in 
      {AssertEquals {P2T P1} E1 'TestEmptyChords'}
   end
      
   proc {TestP2T P2T}
      {TestNotes P2T}
      {TestChords P2T}
      {TestIdentity P2T}
      {TestDuration P2T}
      {TestStretch P2T}
      {TestDrone P2T}
      {TestMute P2T}
      {TestTranspose P2T}
      {TestP2TChaining P2T}
      {TestEmptyChords P2T}   
      {AssertEquals {P2T nil} nil 'nil partition'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % TEST Mix

   proc {TestSamples P2T Mix}
     % E1 = [0.1 ~0.2 0.3]
      %M1 = [samples(E1)]
      skip
   %in
      %{AssertEquals {Mix P2T M1} E1 'TestSamples: simple'}
   end
   
   proc {TestPartition P2T Mix}
      skip
   end
   
   proc {TestWave P2T Mix}
      skip
   end

   proc {TestMerge P2T Mix}
      skip
   end

   proc {TestReverse P2T Mix}
      skip
   end

   proc {TestRepeat P2T Mix}
      skip
   end

   proc {TestLoop P2T Mix}
      skip
   end

   proc {TestClip P2T Mix}
      skip
   end

   proc {TestEcho P2T Mix}
      skip
   end

   proc {TestFade P2T Mix}
      skip
   end

   proc {TestCut P2T Mix}
      skip
   end

   proc {TestMix P2T Mix}
      {TestSamples P2T Mix}
      {TestPartition P2T Mix}
      {TestWave P2T Mix}
      {TestMerge P2T Mix}
      {TestRepeat P2T Mix}
      {TestLoop P2T Mix}
      {TestClip P2T Mix}
      {TestEcho P2T Mix}
      {TestFade P2T Mix}
      {TestCut P2T Mix}
      %{AssertEquals {Mix P2T nil} nil 'nil music'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc {Test Mix P2T}
      {Property.put print print(width:100)}
      {Property.put print print(depth:100)}
      {System.show 'tests have started'}
      {TestP2T P2T}
      {System.show 'P2T tests have run'}
      {TestMix P2T Mix}
      {System.show 'Mix tests have run'}
      {System.show test(passed:@PassedTests total:@TotalTests)}
   end
end