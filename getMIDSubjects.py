#!/usr/bin/python

# script to return subject ids for subjects in this experiment. To use in a python script, do: 

		# from getMIDSubjects import getsubs
		# subjects = getsubs()

# returns subjects as a list of subject id strings. Optional input of task string will return only subjects for that task (mid, etc.), e.g.:

		# from getMIDSubjects import getsubs
		# subjects = getsubs('mid')

import os,sys,csv


def getsubs(task='mid'):

	# get path for main project directory (assumes this is 1 directory up)
	main_dir=os.path.abspath('..')


	# define path to subject file
	subjFile = main_dir+'/subjects_list.csv'


	# define subjects and gi lists
	subjects = [] # list of subject ids

	# index of which subjects to keep for this task
	mid_idx=[]

	# read in subject list 
	with open(subjFile, "r") as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=',')
		next(csv_reader) # skip the header line
		for lines in csv_reader:
			subjects.append(lines[0])
			mid_idx.append(lines[1])

	if task=='mid':     	

		# if an entry in the "mid" column is 0, that means this subject 
		# should be omitted from mid analyses. Get an index of any subjects to exclude.
		omit_idx=[i for i, e in enumerate(mid_idx) if e == '0']
		for idx in sorted(omit_idx, reverse=True):
			del subjects[idx]


	# return subjects 
	return subjects




if __name__ == "__main__":
	subjects = getsubs(sys.argv[1])
	print ' '.join(subjects)
#	print gi


#	if __name__ == "__main__":
 #   	getsubs()
 # getsubs(int(sys.argv[1]))

