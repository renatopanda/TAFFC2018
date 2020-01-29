# TAFFC2018 - "Novel audio features for music emotion recognition"

This repository contains (WIP) scripts to reproduce the classification results obtained in our TAFFC paper [1](#references).

At the moment only one script is available (`best_result.R`), used to obtain the F1-Score of 0.7651 with the best 100 features (standard and novel). 

## Data
The features extracted, annotations, feature ranking and metadata are all available inside the *data/* folder. For more details check our [website](http://mir.dei.uc.pt) and the original paper [1](#references).

## Installation

The classification script is written in R language. Thus, [R](https://www.r-project.org/) is needed and [RStudio](https://rstudio.com/) is recommended too.

For reproducibility purposes this project uses the `renv` package/dependency manager. When the project is loaded the exact versions of the packages used (and R) are installed locally. It should also set the working directory to the current folder.


## Usage

The script can be run with Rstudio or using R command line directly. Both should open the `.Rprofile` file and configure the environment. In both cases you should get the following output
```r
* Project '<PATH_TO_PROJECT>/TAFFC2018' loaded. [renv 0.9.2]
```

### RStudio
Open the TAFFC2018.Rproj file using RStudio and wait for the initial environment setup. After that run:
```r
source('best_result.R')
``` 

### R Command Line
Open an R command line in the project folder, e.g., by executing:
```bash
X:\TAFFC2018>"C:\Program Files\R\R-3.6.1\bin\R.exe"
```

After the environment configuration just run:
```r
source('best_result.R')
```

## Expected Output

```plaintext
Seed Value =  1 (replicability purposes)
FEATURES USED ( 100 ): SET = PANDA TAFFC2018 ( 900 ) 10 fold cv x 20 reps / svm type = C-classification / kernel = radial 
quadrant_annotations
 Q1  Q2  Q3  Q4 
225 225 225 225 
SVM params optimized: cost = 8 / gamma = 0.001953125 
Accuracy = 0.7619892 (std = 0.04071989 )
Precision: macro weighted = 0.7683199 (std = 0.03988924 )
Recall: macro weighted = 0.7619892 (std = 0.04071989 )
F1-Score: macro weighted = 0.7651222 (std = 0.04014196 )
Q1: Precision = 0.7477606 / Recall = 0.8162222  / F1 Score = 0.780493 
Q2: Precision = 0.8888889 / Recall = 0.848  / F1 Score = 0.8679632 
Q3: Precision = 0.7184797 / Recall = 0.7015556  / F1 Score = 0.7099168 
Q4: Precision = 0.697796 / Recall = 0.6824444  / F1 Score = 0.6900348 
Confusion Matrix: 
      y_pred
y_true     Q1     Q2     Q3     Q4
    Q1 183.65  14.10   9.10  18.15
    Q2  23.55 190.80   6.80   3.85
    Q3  14.30   8.35 157.85  44.50
    Q4  24.10   1.40  45.95 153.55
```


## References
[1] Panda, R., Malheiro, R., & Paiva, R. P. (2018). [Novel audio features for music emotion recognition](http://mir.dei.uc.pt/pdf/Journals/MOODetector/TAFFC_2018_Panda.pdf). IEEE Transactions on Affective Computing – TAFFC, 1–1. [http://doi.org/10.1109/TAFFC.2018.2820691](http://doi.org/10.1109/TAFFC.2018.2820691)
