# Read in required packages
library(dplyr)
library(tidyr)

# ********** Section 0: Initializing test & training data **********

# Read in labels (features) for the 561 variables
features <- read.table("./UCI HAR Dataset/features.txt")

# Read in activity labels (e.g. walking, standing) & activity numeric ID
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")

# Read in subject ID for the training and test data
subjectIDtrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")[,1]
subjectIDtest <- read.table("./UCI HAR Dataset/test/subject_test.txt")[,1]

# Read in activity numeric ID for the training and test data
activityTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
activityTest <- read.table("./UCI HAR Dataset/test/y_test.txt")

# Create a row number column for activity table to preserve order
activityTrain$rowID <- as.integer(row.names(activityTrain))
activityTest$rowID <- as.integer(row.names(activityTest))

# Merge the activity tables with the activity label table 
activityTrain <- merge(activityTrain, activityLabels, by = "V1")
activityTest <- merge(activityTest, activityLabels, by = "V1")

# Order the activity table by the way it was presented before the merge
activityTrain <- activityTrain[order(activityTrain$rowID), 3]
activityTest <- activityTest[order(activityTest$rowID), 3]

# Read in the main training and test tables
trainingData <- read.table("./UCI HAR Dataset/train/X_train.txt")
testData <- read.table("./UCI HAR Dataset/test/X_test.txt")

# Expand training and test tables to include subject ID and activity name
trainingData <- 
    data.frame(subjectID = subjectIDtrain, activity = activityTrain,
               trainingData)
testData <- 
    data.frame(subjectID = subjectIDtest, activity = activityTest,
               testData)
# Rename the columns to match the features labels
names(trainingData) <- c("subjectID", "activity", features$V2)
names(testData) <- c("subjectID", "activity", features$V2)

# ********** Section 1: Concatenate test & training data tables**********

# Use rbind function to stack training and test data together
baseData <- bind_rows("Training" = trainingData, 
                      "Test" = testData, .id = "group")
baseData$group <- as.factor(baseData$group)

# Sort the data by subjectID & activity
baseData <- arrange(baseData, subjectID, activity)

# ********** Section 2: Selecting only mean & std dev measures**********

# Using grep function to select columns with string "mean" or "std"
filteredData <- baseData[,c(1, 2, 3, 
                (setdiff(grep("mean|std", names(baseData)),
                grep("meanFreq", names(baseData)))))]

# ********** Section 3: Reassigning activity labels**********

# Converting activity to factor variable
filteredData$activity <- as.factor(filteredData$activity)
# Reassigning names of levels
levels(filteredData$activity) <- c("Laying", "Sitting", "Standing",
                                   "Walking", "Walking Downstairs",
                                   "Walking Upstairs")

# ********** Section 4: Making column names more descriptive **********

# Create separate data frame containing current names of the variables
featureNames <- data.frame(name = names(filteredData))

# Write functions which will help will help find field attributes
axialPosition <- function(a) {
    x <- strsplit(a, "-X")
    y <- strsplit(a, "-Y")
    z <- strsplit(a, "-Z")
    
    if(nchar(x[[1]]) < nchar(y[[1]]) & nchar(x[[1]]) < nchar(z[[1]])) {
        axialSignal <- "X"
    }
    else if(nchar(y[[1]]) < nchar(x[[1]]) & nchar(y[[1]]) < nchar(z[[1]])) {
        axialSignal <- "Y"
    }
    else if(nchar(z[[1]]) < nchar(x[[1]]) & nchar(z[[1]]) < nchar(y[[1]])) {
        axialSignal <- "Z"
    }
    else {
        axialSignal <- "NA"
        } 
    axialSignal
}

signalType <- function(a) {
    acc <- strsplit(a, "Acc")
    gyro <- strsplit(a, "Gyro")
    
    if(nchar(acc[[1]]) < nchar(gyro[[1]])) {
        type <- "Accelerometer"
    }
    else if(nchar(gyro[[1]]) < nchar(acc[[1]])) {
        type <- "Gyroscope"
    }
    else {
        type <- "NA"
    } 
    type
}

signalSubType <- function(a) {
    body <- strsplit(a, "Body")
    gravity <- strsplit(a, "Gravity")
    
    if(nchar(body[[1]]) < nchar(gravity[[1]])) {
        SubType <- "Body"
    }
    else if(nchar(gravity[[1]]) < nchar(body[[1]])) {
        SubType <- "Gravity"
    }
    else {
        SubType <- "NA"
    } 
    SubType
}

transformType <- function(a) {
    jerk <- strsplit(a, "Jerk")
    magnitude <- strsplit(a, "Mag")
    
    if(nchar(jerk[[1]]) < nchar(magnitude[[1]])) {
        transformType <- "Jerk"
    }
    else if(nchar(magnitude[[1]]) < nchar(jerk[[1]])) {
        transformType <- "Magnitude"
    }
    else {
        transformType <- "NA"
    } 
    transformType
}

measureType <- function(a) {
    avg_val <- strsplit(a, "mean()")
    stan_dev <- strsplit(a, "std()")
    
    if(nchar(avg_val[[1]]) < nchar(stan_dev[[1]])) {
        measureType <- "Mean"
    }
    else if(nchar(stan_dev[[1]]) < nchar(avg_val[[1]])) {
        measureType <- "Standard.Deviation"
    }
    else {
        measureType <- "NA"
    } 
    measureType
}

# Domain signal type (Identified by the prefix)
featureNames$domainSignal <- ifelse(
    substr(names(filteredData), 1, 1) == "t", "Time",
    ifelse(substr(names(filteredData), 1, 1) == "f", "Frequency",
           "NA")
)
featureNames$signalType <- sapply(names(filteredData), signalType)
featureNames$signalSubType <- sapply(names(filteredData), signalSubType)
featureNames$transformType <- sapply(names(filteredData), transformType)
featureNames$axialPosition <- sapply(names(filteredData), axialPosition)
featureNames$measureType <- sapply(names(filteredData), measureType)

# Descriptive column name creation
columnNameDesc <- ifelse(names(filteredData) %in% 
                             c("group", "subjectID", "activity"),
                         names(filteredData),
            paste(featureNames$domainSignal, featureNames$signalType,
                  featureNames$signalSubType,featureNames$transformType,
                  featureNames$axialPosition, featureNames$measureType,
                  sep = "_"))

# Reassign column names with descriptive titles
names(filteredData) <- columnNameDesc 

# ********** Section 5: Create tidy data table **********

tidy_data_v0 <- filteredData[,c(2,3, grep("_Mean", names(filteredData)))]
tidy_human_activity_data <- 
        tidy_data_v0 %>%
        gather(measure, value, -c(subjectID, activity)) %>%
        group_by(subjectID, activity, measure) %>%
        summarize(average = mean(value, na.rm = TRUE), .groups = "keep") %>%
        separate(measure, 
                 c("domainSignal", "signalType", "signalSubType",
                   "transformType", "axialPosition", "measureType")) %>%
        select(subjectID, activity, domainSignal, signalType, signalSubType,
               transformType, axialPosition, average)
       