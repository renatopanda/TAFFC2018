###################################################################
# “Novel audio features for music emotion recognition”
#
# This simple script can be used to replicate the classification
# results obtained in our TAFFC 2018 paper [1].
# The set of best features features are loaded and 20 repetitions
# of 10-fold cross validation runs are executed (SVM).
#
# For reproducibility purposes this project uses the renv package.
# When the project is loaded the exact versions of the packages
# used (and R) are installed locally. For more details check the
# REAME.md and our website.
# 
#
# [1] “Novel audio features for music emotion recognition”
# IEEE Transactions on Affective Computing
# Panda R., Malheiro R. & Paiva R. P. (2018)
# DOI: 10.1109/TAFFC.2018.2820691.
# 
# Renato Panda - panda@dei.uc.pt
# http://mir.dei.uc.pt/
# https://github.com/renatopanda/TAFFC2018
###################################################################

# set the working directory to the current dir.
# goal: use relative paths to find the datafiles.
# setwd("D:/Users/Renato Panda/Desktop/MIR/TAFFC2018/")
# setwd(getSrcDirectory()[1])

# load libraries
library(caret)
library(e1071)
library(MLmetrics)
#library(matrixStats)
library(stringr)

#-----------------------------------------------------
# getIndices - small helper function
#-----------------------------------------------------
# arguments:
#   - columnnames: a list of column names (strings)
#   - subset: a subset of column names
# returns:
#   - Indices of the subset in the columnames list
#-----------------------------------------------------
getIndices <- function(columnnames, subset) {
  featIndices <- vector("integer", length(subset))
  for (i in 1:length(subset)) {
    featIndices[i] <- which(columnnames %in% subset[i])
  }
  featIndices
}


#-----------------------------------------------------
# Parameters setup
#-----------------------------------------------------
feature_names <- read.csv("data/features.csv", sep = ";")
features_all <- read.csv("data/all_features.csv", sep = ",", check.names = FALSE) # caution with check.names!
annotations <- read.csv("data/panda_dataset_taffc_annotations.csv", sep = ",")
ranking_file <- "data/allmusicBIG_ReliefF_ALLNEW_Quadrant_900_base990_20171017-2249_newfeats_N_voice_decorr.RData"
repetitions <- 20
folds <- 10
seed_value <- 1 # fixed to 1 for replicability purposes
svm_kernel <- "radial" # others = linear, polynomial, sigmoid
svm_type <- "C-classification" # others nu-classification or one-classification
svm_cost <- 8
svm_gamma <- 0.001953125
features_to_use <- 100 # number of features to use (the topN features from the list of ranked features)


#-----------------------------------------------------
# Load datasets (features, annotations, ranking)
#-----------------------------------------------------

# Load the ranked list of features (computed previously with Relief)
load(ranking_file)
ranked_features <- names(rankFeatsEval[1:features_to_use])
rm(featEvalMean, rankFeatsEval, ranking_file, today)

# Get the index of the features belonging to the top N features
ranked_features_idx <- getIndices(names(features_all), ranked_features)

# Select only the relevant features and annotation labels
features_set <- features_all[, ranked_features_idx]
quadrant_annotations <- as.character(annotations$Quadrant)

# Get the list of unique labels (Q1 to Q4)
labels <- unique(quadrant_annotations)


#-----------------------------------------------------
# Run the classification test
#-----------------------------------------------------

# Set the initial seed value so results can be replicated by others
set.seed(seed_value)

# Arrays to hold the results of each run (reps x folds)
precision_macro_mat <- matrix(0, nrow = repetitions, ncol = folds) # holds the best feature' results
recall_macro_mat <- matrix(0, nrow = repetitions, ncol = folds) # each feature being tested
fscore_macro_mat <- matrix(0, nrow = repetitions, ncol = folds) # holds the best feature' results
accuracy_mat <- matrix(0, nrow = repetitions, ncol = folds) # each feature being tested
predictions_mat <- matrix('-', nrow = length(quadrant_annotations), ncol = repetitions)

# Repeat classification for N reps (times) K folds
for (repNumber in c(1:repetitions)) {

  # Divide dataset into folds
  selectedFolds <- createFolds(quadrant_annotations, folds)
  
  for (foldNumber in c(1:folds)) {
    cat("Running repetition", repNumber, "of", repetitions,"/ fold", foldNumber, "of", folds, "\n")
    
    # Build the training set
    trainIdx <- selectedFolds
    trainIdx[[foldNumber]] <- NULL
    trainIdx <- unlist(trainIdx, use.names = FALSE)
    
    # and the test set
    testIdx <- selectedFolds[[foldNumber]]

    # Model learning - train the SVM classification model
    svmTrain <- svm(features_set[trainIdx,], quadrant_annotations[trainIdx], kernel = svm_kernel, type=svm_type, scale = TRUE, gamma = svm_gamma, cost = svm_cost)
   
    # Predict values for the test set
    predictions <- predict(svmTrain, features_set[testIdx,])
    
    # Compute prediction metrics (matro_weighted functions come from my github R package (PR yet to be accepted by MLMetrics author))
    pred_acc <- Accuracy( y_true = quadrant_annotations[testIdx], y_pred = predictions)
    pred_prec_macro_weighted <- Precision_macro_weighted( y_true = quadrant_annotations[testIdx], y_pred = predictions, labels)
    pred_recall_macro_weighted <- Recall_macro_weighted( y_true = quadrant_annotations[testIdx], y_pred = predictions, labels)
    pred_fscore_macro_weighted <- F1_Score_macro_weighted( y_true = quadrant_annotations[testIdx], y_pred = predictions, labels)
    
    predictions_mat[testIdx,repNumber] <- as.character(predictions)
    accuracy_mat[repNumber, foldNumber] <- pred_acc
    precision_macro_mat[repNumber, foldNumber] <- pred_prec_macro_weighted
    recall_macro_mat[repNumber, foldNumber] <- pred_recall_macro_weighted
    fscore_macro_mat[repNumber, foldNumber] <- pred_fscore_macro_weighted
  }
  
}

#-----------------------------------------------------
# Compute final (global) results
#-----------------------------------------------------

predictions_list <- unlist(predictions_mat)
annotations_list <- rep(quadrant_annotations, repetitions)
pred_acc_mean <- mean(accuracy_mat)
pred_acc_std <- sd(accuracy_mat)
pred_prec_mean <- mean(precision_macro_mat)
pred_prec_std <- sd(precision_macro_mat)
pred_recall_mean <- mean(recall_macro_mat)
pred_recall_std <- sd(recall_macro_mat)
pred_fscore_mean <- mean(fscore_macro_mat)
pred_fscore_std <- sd(fscore_macro_mat)

cm <- ConfusionMatrix( y_true = annotations_list, y_pred = predictions_list)


#-----------------------------------------------------
# Output results to console
#-----------------------------------------------------

cat("Seed Value = ", seed_value, "(replicability purposes)\n")
cat('FEATURES USED (', features_to_use, '): SET = PANDA TAFFC2018 (', length(quadrant_annotations), ')', folds, 'fold cv x', repetitions, 'reps / svm type =', svm_type,'/ kernel =', svm_kernel,'\n')
print(table(quadrant_annotations))

cat('SVM params optimized: cost =', svm_cost, '/ gamma =', svm_gamma,'\n')

cat('Accuracy =', pred_acc_mean, '(std =', pred_acc_std,')\n')
cat('Precision: macro weighted =', pred_prec_mean, '(std =', pred_prec_std,')\n')
cat('Recall: macro weighted =', pred_recall_mean, '(std =', pred_recall_std,')\n')
cat('F1-Score: macro weighted =', pred_fscore_mean, '(std =', pred_fscore_std,')\n')
cat('Q1: Precision =', Precision(y_true = annotations_list, y_pred = predictions_list,positive = "Q1") ,'/ Recall =', Recall(y_true = annotations_list, y_pred = predictions_list,positive = "Q1") , ' / F1 Score =', F1_Score(y_true = annotations_list, y_pred = predictions_list,positive = "Q1"), '\n')
cat('Q2: Precision =', Precision(y_true = annotations_list, y_pred = predictions_list,positive = "Q2") ,'/ Recall =', Recall(y_true = annotations_list, y_pred = predictions_list,positive = "Q2") , ' / F1 Score =', F1_Score(y_true = annotations_list, y_pred = predictions_list,positive = "Q2"), '\n')
cat('Q3: Precision =', Precision(y_true = annotations_list, y_pred = predictions_list,positive = "Q3") ,'/ Recall =', Recall(y_true = annotations_list, y_pred = predictions_list,positive = "Q3") , ' / F1 Score =', F1_Score(y_true = annotations_list, y_pred = predictions_list,positive = "Q3"), '\n')
cat('Q4: Precision =', Precision(y_true = annotations_list, y_pred = predictions_list,positive = "Q4") ,'/ Recall =', Recall(y_true = annotations_list, y_pred = predictions_list,positive = "Q4") , ' / F1 Score =', F1_Score(y_true = annotations_list, y_pred = predictions_list,positive = "Q4"), '\n')


cat('Confusion Matrix:', '\n')
print(cm/repetitions)

