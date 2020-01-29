Panda et al. TAFFC Dataset - 2018
http://mir.dei.uc.pt


Dataset used in our IEEE TAFFC article:
Panda, P., Malheiro, R. & Paiva, R. P. (2018). “Novel audio features for music emotion recognition”. IEEE Transactions on Affective Computing (accepted for publication).

- The dataset consists of:
 *) 900 ~30 second clips gathered from AllMusic API
 *) The files are organized in 4 folders (Q1 to Q4)
 *) Two metadata csv files with annotations and extra metadata

- Due to size and bandwidth constraints the files are in mp3.
In our works they were converted to the same format used in MIREX:
22 KHz
Sample size: 16 bit
Number of channels: 1 (mono)
Encoding: WAV 


The metadata file contains the following columns:
"Song" - The Song name or ID used in AllMusic.
"Artist" - Name of the artist(s).
"Title" - Song title.
"Quadrant" - The annotation, Russell's quadrant obtained as described in the paper.
"PQuad" - Ratio of mood tags from "Quadrant" against all moods.
"MoodsTotal" - Total number of moods associated with the song.
"Moods" - Number of moods that matched the Warriner's list
"MoodsFoundStr" - moods that were found
"MoodsStr" - original list of all moods associated with the song entry.
"MoodsStrSplit" - same as above but with moods split (for the few tags originally containing two words)
"Genres" - Number of genres
"GenresStr" - List of genres 
"Sample" - 1/true, since all songs contain sample
"SampleURL" - the sample URL.
