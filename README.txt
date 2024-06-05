Both sets of codes are used to process, analyze, and plot files generated using MedAssociates Davis Rig Software.

---------------------------------PYTHON-------------------------------------
The BAT_reader.py file requires user's to indicate directory where the desired '.txt' files to be processed are located. The functions herein read each file, create dictionaries of file/session information (e.g.subject ID, trials), and merge data into a population DataFrame of all animals/sessions. Following the processing of each file within the provided directory, the DataFrame will be exported as a '.csv' timestamped with the date of processing.  

The BAT_reader.py file has an option to call on an input file (sample file included 'Sample_inputfile.txt') which carries important information/categorical labels/session details to insert into DataFrame during its construction. 

The BAT_Plotting.py code is under construction, yet has basic features built in which read in the exported DataFrame csv file (created using BAT_reader.py) and allows users to plot various types of figures.

#Setup:



---------------------------------MATLAB-------------------------------------
The MATLAB codes create large datastructures for every session and store each subject who completed said session within respective structure. Each structure will contain the entire session's lick data, naming parameters, ILI data, and a few more "logic" vectors for ease of data handling.

These structures can be used with the series of functions and scripts provided for quick "snapshot" details of subject's licking behavior, microstructure analyses, and plotting. 

Unfortunately, these files/scripts are not 100% dynamic and will require tweaking on user's end to ensure proper processing and matrix mathematics.
