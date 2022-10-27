const { readFileSync, writeFileSync } = require("fs");
path = process.argv[2]
/**const fna_filename = "../Output_Files/TSD_Input_BLAST_Seq.fa";
const output_filename = "../Output_Files/TSD_Output_BLAST_Seq.txt";**/
const fna_filename = path+"/Step1_extend_tsd_input.fa";
const output_filename = path+"/Step2_tsd.txt";
const LeftOffset = 0;
const RightOffset = 0;
const LeftRange = 50;
const RightRange = 70;


const R1Len = 1;
const SLen = 1;
const R2Len = 1;
const S2Len = 1;
const R3Len = 1;
const MatchLenThr = 10;
const MismatchLenThr = 1;
const TSDNum = 3;


function TSDsearch(faSeq) {
  /**console.log("Start searching TSDs for sequence:");**/
  /**console.log(faSeq);**/
  var Match, TSDre, TSD1, TSD2, j;
  var Pos1 = 0,
    Pos2 = 0,
    i = 0,
    TSD = [];
  var SeqMatch = faSeq.match(/^>(\S+).*[\n\f\r]+([\w ~\-\t\n\f\r]+)/i);
  var sn = SeqMatch[1];
  var sq = SeqMatch[2].replace(/[ ~\-\t\n\f\r]/g, "");
  var Seq =
    sq.substr(LeftOffset, LeftRange) +
    "######" +
    sq.substr(sq.length - RightOffset - RightRange, RightRange);
  var TSDptn1 = "^[ACGT]{"; /* left offset */
  var TSDptn2 = "}([ACGT]{" + R1Len + ",})"; /* #1 subrepeat 1 */
  TSDptn2 += "([ACGT]{0," + SLen + "}?)"; /* #2 spacer 1/2 */
  TSDptn2 += "([ACGT]{" + R2Len + ",})"; /* #3 subrepeat 2 */
  TSDptn2 += "([ACGT]{0," + SLen + "}?)"; /* #4 spacer 2/3 */
  TSDptn2 += "([ACGT]{" + R3Len + ",})"; /* #5 subrepeat 2 */
  TSDptn2 += "[ACGT]*#{6}[ACGT]{"; /* spacer between repeats */
  var TSDptn3 = ",}?(\\1)"; /* #6 subrepeat 1 */
  TSDptn3 += "([ACGT]{0," + SLen + "}?)"; /* #7 spacer 1/2 */
  TSDptn3 += "(\\3)"; /* #8 subrepeat 2 */
  TSDptn3 += "([ACGT]{0," + SLen + "}?)"; /* #9 spacer 2/3 */
  TSDptn3 += "(\\5)"; /* #10 subrepeat 3 */
  TSDptn3 += "([ACGT]*$)"; /* #11 seq after TSD 2 */


  while (Pos1 < LeftRange - MatchLenThr) {
    Pos2 = 0;
    TSDre = new RegExp(TSDptn1 + Pos1 + TSDptn2 + Pos2 + TSDptn3, "i");
    Match = TSDre.exec(Seq);
    while (
      Match &&
      Match[1].length + Match[3].length + Match[5].length >= MatchLenThr &&
      Math.max(Match[2].length, Match[7].length) +
        Math.max(Match[4].length, Match[9].length) <=
        MismatchLenThr
    ) {
      TSD1 = Match[1].toUpperCase() + Match[2].toLowerCase();
      TSD2 = Match[6].toUpperCase() + Match[7].toLowerCase();
      while (TSD1.length > TSD2.length) {
        TSD2 += "-";
      }
      while (TSD2.length > TSD1.length) {
        TSD1 += "-";
      }
      TSD1 += Match[3].toUpperCase() + Match[4].toLowerCase();
      TSD2 += Match[8].toUpperCase() + Match[9].toLowerCase();
      while (TSD1.length > TSD2.length) {
        TSD2 += "-";
      }
      while (TSD2.length > TSD1.length) {
        TSD1 += "-";
      }
      TSD1 += Match[5].toUpperCase();
      TSD2 += Match[10].toUpperCase();
      TSD[i] = [
        LeftOffset + Match.index + Pos1 + 1,
        TSD1.match(/[ACGT]/gi).length,
        sq.length -
          RightOffset -
          Match[11].length -
          TSD2.match(/[ACGT]/gi).length +
          1,
        TSD2.match(/[ACGT]/gi).length,
        TSD1,
        TSD2,
        Math.pow(Match[1].length + Match[3].length + Match[5].length, 2) /
          TSD1.length,
      ];
      for (j = 0; j < TSD.length - 1; ++j) {
        if (
          TSD[i][0] >= TSD[j][0] &&
          TSD[i][0] + TSD[i][1] <= TSD[j][0] + TSD[j][1] &&
          TSD[i][2] >= TSD[j][2] &&
          TSD[i][2] + TSD[i][3] <= TSD[j][2] + TSD[j][3]
        ) {
          TSD.pop();
          --i;
          break;
        }
      }
      i++;
      Pos2 =
        RightRange -
        Match[11].length -
        Match[10].length -
        Match[9].length -
        Match[8].length -
        Match[7].length -
        Match[6].length +
        1;
      TSDre = new RegExp(TSDptn1 + Pos1 + TSDptn2 + Pos2 + TSDptn3, "i");
      Match = TSDre.exec(Seq);
    } /* end of while Match && ... */
    Pos1++;
  } /* end of while Pos1 loop */
  TSD = TSD.sort(function (a, b) {
    return b[6] - a[6];
  });
  /**console.log(`=> Result: found ${TSD.length} pairs of TSDs\n`);**/
  return TSD;
} /* end of TSDsearch() */

const file = readFileSync(fna_filename, "utf-8");
const FNA_HEAD_PATTERN = "(?<head>>[^\n]*\n)";
const FNA_SEQUENCE_PATTERN = "(?<sequence>[atcgATCG\n]+)";
const FNA_PATTERN = new RegExp(FNA_HEAD_PATTERN + FNA_SEQUENCE_PATTERN, "g");


// count number of headers
const seq_number = (file.match(/>/g) || []).length;
console.log(
  `Find ${seq_number} sequence headers in the input file: ${fna_filename}\n`
);


const sequences = Array.from(file.matchAll(FNA_PATTERN)).map(
  ({ groups }) =>
    groups && {
      head: groups.head,
      sequence: groups.sequence.replace(/\n/g, "").trim(),
    }
);


if (seq_number !== sequences.length) {
  // Make sure we won't miss any sequence.
  throw new Error(
    `Should be ${seq_number} sequences, but parsed ${sequences.length}`
  );
}


const result = sequences.map(({ head, sequence: seq }) => ({
  head,
  tsds: TSDsearch(head + seq),
}));


function formatTSDResult(result) {
  const output_header = [
    ">",
    "left_sequence",
    "left_start",
    "left_end",
    "right_sequence",
    "right_start",
    "right_end",
  ].join(" ");
  return (
    output_header +
    "\n" +
    result
      .map(({ head, tsds }) => {
        return head.split('|')[0].trim() + '\n' + tsds.map(([leftStart, leftLength, rightStart, rightLength, LeftSeq, rightSeq]) =>
        (`${LeftSeq} (${leftStart}-${leftStart + leftLength - 1}) ${rightSeq} (${rightStart}-${rightStart + rightLength - 1})`)).join(' ');
      })
      .join("\n") + "\n"
  );
}


console.log(`Start writing result to file: ${output_filename}`);
writeFileSync(output_filename, formatTSDResult(result));
console.log("Succeeded!");