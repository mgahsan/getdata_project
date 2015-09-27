## Note: The script will run on the working directory of the user. Any new file downloaded,
## manipulated or created will be saved on the same location.

## Downloading the file directly from web and unzipping: The if structure saves time on 
## consecutive uses of the script.

if (!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")){
    dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(dataURL, destfile =  "getdata-projectfiles-UCI HAR Dataset.zip")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip("getdata-projectfiles-UCI HAR Dataset.zip") 
}

## Loading activity labels and features:

activities.labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activities.labels[,2] <- as.character(activities.labels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Extract only the data on mean and standard deviation, i.e., the interesting features
## from data

interesting.features <- grep(".*mean.*|.*std.*", features[,2])
interesting.features.names <- features[interesting.features,2]
interesting.features.names <- gsub('-mean', 'Mean', interesting.features.names)
interesting.features.names <- gsub('-std', 'Std', interesting.features.names)
interesting.features.names <- gsub('[-()]', '', interesting.features.names)

## Load the datasets for training and training subjects:

training <- read.table("UCI HAR Dataset/train/X_train.txt")[interesting.features]
training.activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
training.subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(training.subjects, training.activities, training)

## Load the datasets on tests and test subjects:

tests <- read.table("UCI HAR Dataset/test/X_test.txt")[interesting.features]
tests.activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
tests.subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
tests <- cbind(tests.subjects, tests.activities, tests)

## Merge datasets on training and tests

merged.data <- rbind(training, tests)
colnames(merged.data) <- c("subjects", "activities", interesting.features.names)

## convert the variables activities & subjects into factors

library(reshape2)

merged.data$activities <- factor(merged.data$activities, levels = activities.labels[,1], labels = activities.labels[,2])
merged.data$subjects <- as.factor(merged.data$subjects)

data.melt <- melt(merged.data, id = c("subjects", "activities"))
data.mean <- dcast(data.melt, subjects + activities ~ variable, mean)

## Finally write the tidy data set

write.table(data.mean, "tidy_data.txt", row.names = F, quote = F)
