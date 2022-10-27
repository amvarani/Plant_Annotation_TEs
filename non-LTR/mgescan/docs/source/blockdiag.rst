MGEScan Software Process
===============================

.. blockdiag::

  diagram {
  
  orientation = portrait

   Chromosomes [shape = flowchart.input, stacked];
   nonLTR [ numbered = MPI ];
   LTR [ numbered = MPI ];
   
   Chromosomes -> MGEScan -> nonLTR -> 'Forward Strand' -> "Translation \n to Protein" -> "Signals of APE" -> 'E-values \n from 12 clades' -> 'Searching \n Path of States' -> 'Classification \n (post processing)' -> 'Results \n(gff3)';
   nonLTR -> 'Reverse Strand' -> "Translation \n to Protein";
   "Translation \n to Protein" -> 'Signals of RT' -> 'E-values \n from 12 clades';

   group { 
   label = 'HMMER';
   color='#E6E6E6';
   "Signals of APE";
   "Signals of RT";
   'E-values \n from 12 clades';
   }
   
   group { 
   label = 'C program';
   color='#E6E6E6';
   'Searching \n Path of States';
   }
   
   group { 
   label = 'HMMER';
   color='#E6E6E6';
   'Classification \n (post processing)' ;
   }
   
   Chromosomes -> MGEScan -> LTR -> "Tandem Repeat Finder\n(TRF)" -> "Finding pairs \nof Maximal Exact \nrepeats" -> 'Identifying \nputative LTRs' -> 'Analysis of RT \n/ Scanning ORFs' -> 'Deleting fragments' ->  'Results \n(gff3)';
   
   group {
   label = 'GAME';
   color='#E6E6E6';
   "Finding pairs \nof Maximal Exact \nrepeats";
   }
   
   group {
   label = 'EMBOSS';
   color='#E6E6E6';
   'Identifying \nputative LTRs';
   
   }
   
   group {
   label = ' HMMER, EMBOSS';
   color='#E6E6E6';
   'Analysis of RT \n/ Scanning ORFs';
   }
   }

* HMMER: hmmsearch 3.1b1 http://hmmer.org/
* EMBOSS: matcher, transeq http://emboss.sourceforge.net/, http://www.ebi.ac.uk/Tools/emboss/
* GAME: Choi, Jeong-Hyeon, Hwan-Gue Cho, and Sun Kim. "GAME: a simple and efficient whole genome alignment method using maximal exact match filtering." Computational biology and chemistry 29.3 (2005): 244-253.
* Tandem Repeats Finder: https://tandem.bu.edu/trf/trf.html
* MGEScan: https://github.com/mgescan/mgescan
