## UCI HAR Dataset/activity_labels.txt
## UCI HAR Dataset/features.txt
## UCI HAR Dataset/test/subject_test.txt
## UCI HAR Dataset/test/X_test.txt
## UCI HAR Dataset/test/y_test.txt
## UCI HAR Dataset/train/subject_train.txt
## UCI HAR Dataset/train/X_train.txt
## UCI HAR Dataset/train/y_train.txt

library(dplyr)
library(reshape2)

## 1. Reading raw data
## 1.1. Activity & activity labels
activity_labels <- read.table(
    "UCI HAR Dataset/activity_labels.txt",
    sep = " ",
    col.names = c("id", "activity")
)
activity_test <- read.table(
    "UCI HAR Dataset/test/y_test.txt",
    col.names = "activity_id"
)
activity_train <- read.table(
    "UCI HAR Dataset/train/y_train.txt",
    col.names = "activity_id"
)

## 1.2. Variable names
variable_names <- read.table(
    "UCI HAR Dataset/features.txt",
    sep = " ",
    col.names = c("id", "variable"),
    stringsAsFactors = F
)

select_variables <- grepl("(mean|std)[()]", variable_names$variable)

variable_names$col_names <- gsub("-|,", "_", variable_names$variable)
variable_names$col_names <- gsub("[()]", "", variable_names$col_names)

## 1.3. Subjects
subject_test <- read.table(
    "UCI HAR Dataset/test/subject_test.txt",
    col.names = "subject"
)
subject_train <- read.table(
    "UCI HAR Dataset/train/subject_train.txt",
    col.names = "subject"
)

## 1.4. Measurements
measurement_test <- read.table(
    "UCI HAR Dataset/test/X_test.txt",
    col.names = variable_names[, "col_names"]
)

measurement_test <- subset(measurement_test, select = select_variables)
measurement_test$subject <- subject_test[, "subject"]
measurement_test$activity_id <- activity_test[, "activity_id"]

measurement_train <- read.table(
    "UCI HAR Dataset/train/X_train.txt",
    col.names = variable_names[, "col_names"]
)

measurement_train <- subset(measurement_train, select = select_variables)
measurement_train$subject <- subject_train[, "subject"]
measurement_train$activity_id <- activity_train[, "activity_id"]

## 1.5. Remove unnecessary variables
rm(subject_test)
rm(activity_test)
rm(subject_train)
rm(activity_train)

## 2. Merging measurement
measurement <- merge(
    rbind(measurement_test, measurement_train),
    activity_labels,
    by.x = "activity_id",
    by.y = "id"
)
measurement$activity_id <- NULL
rm(measurement_test)
rm(measurement_train)
rm(activity_labels)

variable_names <- subset(variable_names, subset = select_variables)
rm(select_variables)

## 3. Creating a second, independent tidy data set with the average of each variable
## for each activity and each subject.
measurement_second <- melt(measurement, id=c("subject", "activity"), measure.vars=variable_names[, "col_names"])
measurement_second <- dcast(measurement_second, subject + activity ~ variable, mean)

## 4. Writing tidy data.
write.table(measurement_second, "measurement_second.csv", row.name = F, sep = ",")
