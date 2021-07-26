# tidy_data_query

The purpose of this code is to read in experimental data relating to tracking human activities (walking, standing, walking upstairs, etc.) using a Samsing Galaxy X II. 

The experimental data originates from several different text files, where the variable names are contained within separate text files.  This creates difficulty with
regard to performing analysis, so the goal of the script is to aggregate the text files such that variable names are provided, identifying characteristics are included
(such as subject ID and activity), and only the measures relating to the mean are provided for simplicity.

=================================================================================================================================================================================
Code Description
=================================================================================================================================================================================

Section 0: Reads in all the various text files, which includes separate training and test datasets.  The measures relating to the activity name and subject ID
are appended to both the test and training datasets, and the columns are renamed to the feature labels provided in a separate text file.

Section 1: The training and test datasets are appended to each other to create one primary analysis table.  It is also sorted by subject ID, then by activity

Section 2: Text functions are used to isolate only the columns measuring the mean or standard deviation

Section 3: Modifies the activity name label to make more visually friendly

Section 4: Searches the text of the column names to extract sub-attributes to make into their own columns in section 5

Section 5: Using the sub-attributes found in Section 4, the data is made tidy by splitting the separate measure characteristics (like signal type and axial position)
into their own columns.

=================================================================================================================================================================================
Code Book
=================================================================================================================================================================================

subjectID - Number identifying one of 30 subjects that participated in the experiment.
activity - Denotes the activity the subject was doing when the smartphone was tracking - includes laying, sitting, standing, walking, walking upstairs, and walking downstairs
domainSignal - Denotes whether the metric relates to frequency or time
signalType - Gyroscope vs. Accelerometer
signalSubType - Body vs. gravity
transformType - Jerk, magnitude, or NA
axialPosition - X, Y, Z, or NA
average - Mean value for the metrics described in the previous columns

