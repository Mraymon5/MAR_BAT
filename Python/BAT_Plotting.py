#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 17 10:03:58 2019

@author: bradly
"""
# =============================================================================
# Import stuff
# =============================================================================
# import Libraries
# Built-in Python libraries
import os # functions for interacting w operating system

# 3rd-party libraries
import numpy as np # module for low-level scientific computing
import easygui
import pandas as pd

#Import statistics packages
import pingouin as pg
from pingouin import pairwise_ttests
import statsmodels.api as sm

#Import plotting utilities
import seaborn as sns
import matplotlib.pyplot as plt
import math

# =============================================================================
# #Define processing functions
# =============================================================================
#Define a padding function
def boolean_indexing(v, fillval=np.nan):
    lens = np.array([len(item) for item in v])
    mask = lens[:,None] > np.arange(lens.max())
    out = np.full(mask.shape,fillval)
    out[mask] = np.concatenate(v)
    return out
# =============================================================================
# #Define a function for sig bar plotting
# =============================================================================

#Custom function to draw the sig bars
def label_pval(i,j,text,X,Y,f_size,color,bar):
    
    #Set the height off of the highest bar
    y =(2)+max(Y)
    
    #Set the text to be in the middle of comparative bars and higher than the bar
    ax.text((X[i]+X[j])*.5, y+3, text, ha='center', va='bottom',size =f_size, color = color)
    
	#Set the bar
    if bar == 'yes':
        ax.plot([X[i],X[j]], [y+2, y+2], lw=1.5, color = color)

# =============================================================================
# #Read in file
# =============================================================================
#Get name of directory where the data files and hdf5 file sits, and change to that directory for processing
dir_name = easygui.diropenbox()
os.chdir(dir_name)

#Look for the ms8 files in the directory
file_list = os.listdir('./')
file_names = []
for files in file_list:
    if files[-3:] == 'csv':
        file_names.append(files)

df_files = easygui.multchoicebox(
        msg = 'Which file do you want to work from?', 
        choices = ([x for x in file_names])) 

#Read in dataframe from CSV
df = pd.read_csv(df_files[0])

#Capitalize labels
df['Notes'] = df['Notes'].str.capitalize()

#Alphabetize the solutions 
sorted_solutions = list(np.sort(np.array(df['SOLUTION'].unique())))

# =============================================================================
# #HABITUATION FIGURES for EACH ANIMAL
# =============================================================================
# =============================================================================
# #HABITUATION BAR GRAPHS
# trimmed_result = df.loc[df.Notes.isin(['Hab4','Hab5'])]
# 
# #Check for bottle bias across habituation days
# g = sns.FacetGrid(trimmed_result, col="Animal",\
# 				  col_order=sorted(trimmed_result.Animal.unique()),\
# 				  height=4, aspect=.5,legend_out=True)
# g = g.map(sns.barplot, "Notes", "LICKS",'TUBE',\
# 		  order =['Hab4','Hab5'],\
# 		  palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1))
# g.axes[0][0].legend()
# leg = g.axes.flat[0].get_legend()
# leg.set_title('Bottle Number')
# =============================================================================

#Create figure
fig,axes = plt.subplots(nrows=math.ceil(len(df.Animal.unique())/4),\
			ncols=4,sharex=True, sharey=True,figsize=(12, 8), squeeze=False)
fig.text(0.5, 0.05, 'Habituation Day', ha='center',fontsize=15,fontweight = 'bold')
fig.text(0.075, 0.5,'Licks', va='center', 
		       rotation='vertical',fontsize=15,fontweight = 'bold')
axes_list = [item for sublist in axes for item in sublist]

#Start animal counter and statistics list
an_count = 0; rm_stats = []

for ax,animal in zip(axes.flatten(),\
	 sorted(df.Animal.unique())):
	 
	#Query animal data
	trimmed_result = df.loc[df.Notes.isin(['Hab4','Hab5'])\
					 & (df['Animal'] == animal)]
	
	#Run ANOVA across bottles
	bottle_stats = []
	for day in sorted(trimmed_result.Notes.unique()):
		stat_query = trimmed_result.loc[(trimmed_result['Notes'] == day)]
		b_stats = stat_query.anova(dv='LICKS', between=['TUBE'])
		bottle_stats.append(np.round(b_stats.iloc[0,4],2))
	
	#Run Repeated Measures ANOVA across days
	stats = pg.rm_anova(dv='LICKS',
                  within=['Notes'],
                  subject='TUBE', data=trimmed_result,  detailed=True)

	pval = np.format_float_scientific(stats.iloc[0,5],1, exp_digits=2)
	rm_stats.append(pval)
		
	#Establish plot location
	ax = axes_list.pop(0)

	#Plot
	sns.barplot(x='Notes',\
				y='LICKS',\
				hue='TUBE',\
				data=trimmed_result,
				order =['Hab4','Hab5'],
				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1),\
				ax=ax)
	
	#Formatting
	ax.set_ylim(0,105)
	ax.set_xlabel('')
	ax.set_ylabel('')
	ax.set_title('%s' %(animal),fontweight = 'bold')
	
	if an_count != 0:
		ax.get_legend().set_visible(False)
	
	an_count +=1
	
	#Establish plotting points for sig bars
	x_pos = np.arange(-0.25,len(stat_query.TUBE.unique()),0.5)
	
	#Flip through groups and call function
	counter = 0
	for stat_group in range(len(bottle_stats)):
	    
	    #create the label
	    color = 'black'
	    if bottle_stats[stat_group] > 0.05:
	        label = 'p = %s' %(bottle_stats[stat_group])
	    if bottle_stats[stat_group] <= 0.05:
	        label = 'p < 0.05'
	        color = 'red'
	    if bottle_stats[stat_group] <= 0.01:
	        label = 'p < 0.01'
	        color = 'red'
	    if bottle_stats[stat_group] <= 0.001:
	        label = 'p < 0.001'
	        color = 'red'
	    
	    #Add label to figure
	    label_pval(counter,\
	               counter+1,\
	               label,x_pos,list([78,0]),10,color,'yes')
	    
	    counter+=2
		
	#Draw repeated_measures bar and stat create the label
	color = 'black'
	if stats.iloc[0,5] > 0.05:
		label = 'p = %s' %(pval)
	if stats.iloc[0,5] <= 0.05:
		label = 'p < 0.05'
		color = 'red'
	if stats.iloc[0,5] <= 0.01:
		label = 'p < 0.01'
		color = 'red'
	if stats.iloc[0,5] <= 0.001:
		label = 'p < 0.001'
		color = 'red'
	
	#Add label to figure
	label_pval(0,1,label,np.arange(0,2),\
			list([90,0]),10,color,'yes')

#Update the legend	
axes[0,0].legend(title='Bottle #',loc=6)	
plt.suptitle('Bottle-Bias Assessment \nHabituation',size=18,fontweight = 'bold')

# =============================================================================
# #TEST FIGURES for EACH ANIMAL
# =============================================================================
#Create figure
fig,axes = plt.subplots(nrows=math.ceil(len(df.Animal.unique())/3),\
			ncols=3,sharex=True, sharey=True,figsize=(12,12), squeeze=False)
fig.text(0.5, 0.05, 'Tastant', ha='center',fontsize=15,fontweight = 'bold')
fig.text(0.075, 0.5,'Licks', va='center', 
		       rotation='vertical',fontsize=15,fontweight = 'bold')
axes_list = [item for sublist in axes for item in sublist]

#Start animal counter and statistics list
an_count = 0; rm_stats = []

for ax,animal in zip(axes.flatten(),\
	 sorted(df.Animal.unique())):
	 
	#Query animal data
	trimmed_result = df.loc[df.Notes.isin(['Test2','Test3'])\
					 & (df['Animal'] == animal)]
	
	
	#Establish plot location
	ax = axes_list.pop(0)
	
	#Run paired T-Test across solutions
	solution_stats_str = []; solution_stats_val = []
	for solution in sorted(trimmed_result.SOLUTION.unique()):
		stat_query = trimmed_result.loc[(trimmed_result['SOLUTION'] == solution)]
		
		stats= pg.pairwise_ttests(dv='LICKS',
	                  within=['Condition'],
	                  subject='Animal', data=stat_query,
					  padjust = 'bonf')

		pval = np.format_float_scientific(stats.iloc[0,8],1, exp_digits=2)
		solution_stats_val.append(stats.iloc[0,8])
		solution_stats_str.append(pval)

	#Plot
	sns.barplot(x='SOLUTION',\
				y='LICKS',\
				hue='Condition',\
				hue_order = ['Saline','Nicotine'],\
				data=trimmed_result,
				order =sorted_solutions,
				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1),\
				ax=ax)
	
	ax.set_xticklabels(labels=sorted_solutions,rotation=60)
	
	#Formatting
	ax.set_ylim(0,150)
	ax.set_xlabel('')
	ax.set_ylabel('')
	ax.set_title('%s' %(animal),fontweight = 'bold')
	
	if an_count != 0:
		ax.get_legend().set_visible(False)
	
	an_count +=1
	
	#Establish plotting points for sig bars
	x_pos = np.arange(-0.25,len(trimmed_result.SOLUTION.unique()),0.5)
	
	#Flip through groups and call function
	counter = 0
	for stat_group in range(len(solution_stats_val)):
	    
	    #create the label
	    color = 'black'
	    if solution_stats_val[stat_group] > 0.05:
	        label = '' 
	    if solution_stats_val[stat_group] <= 0.05:
	        label = '*'
	        color = 'red'
	    if solution_stats_val[stat_group] <= 0.01:
	        label = '**'
	        color = 'red'
	    if solution_stats_val[stat_group] <= 0.001:
	        label = '***'
	        color = 'red'
	    
	    #Add label to figure
	    label_pval(counter,\
	               counter+1,\
	               label,x_pos,list([110,0]),15,color,'no')
	    
	    counter+=2

#Add title
plt.suptitle('Nicotine Impact on Licks',size=18,fontweight = 'bold')
	

# =============================================================================
# #TEST DAY for EACH ANIMAL
# =============================================================================
#Create figure
fig,axes = plt.subplots(nrows=math.ceil(len(df.Animal.unique())/3),\
			ncols=3,sharex=True, sharey=True,figsize=(12,12), squeeze=False)
fig.text(0.5, 0.05, 'Tastant', ha='center',fontsize=15,fontweight = 'bold')
fig.text(0.075, 0.5,'Licks', va='center', 
		       rotation='vertical',fontsize=15,fontweight = 'bold')
axes_list = [item for sublist in axes for item in sublist]

#Start animal counter and statistics list
an_count = 0; rm_stats = []

for ax,animal in zip(axes.flatten(),\
	 sorted(df.Animal.unique())):
	 
	#Query animal data
	trimmed_result = df.loc[df.Notes.isin(['Test1','Test2','Test3'])\
					 & (df['Animal'] == animal)]
	
	
	#Establish plot location
	ax = axes_list.pop(0)

	#Plot
	sns.barplot(x='SOLUTION',\
				y='LICKS',\
				hue='Notes',\
				hue_order = ['Test1','Test2','Test3'],\
				data=trimmed_result,
				order =sorted_solutions,
				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1),\
				ax=ax)
	
	ax.set_xticklabels(labels=sorted_solutions,rotation=60)
	
	#Formatting
	ax.set_ylim(0,150)
	ax.set_xlabel('')
	ax.set_ylabel('')
	ax.set_title('%s' %(animal),fontweight = 'bold')
	
		
	if an_count != 0:
		ax.get_legend().set_visible(False)
	
	an_count +=1

#Add title
plt.suptitle('Nicotine Impact on Licks \nAll Test Days',\
			 size=18,fontweight = 'bold')
		
# =============================================================================
# #Run statistics to ensure that group1 does not vary from group2
# =============================================================================
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Notes'] !='Test1') & \
							(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]

group_nums = easygui.multenterbox(
            msg = 'Input group counts (in case protocol changed during exp)', 
            fields = ['Groups:'], 
            values = ['2'])

#Identify which subjects belong to each group and label dataframe accordingly
group_subs = []
for group in range(int(group_nums[0])):
	group_animals = easygui.multchoicebox(
        msg = 'Which animals belong in group %i?' %(group+1), 
        choices = ([x for x in sorted(df.Animal.unique())])) 
	group_subs.append(group_animals)

#Label dataframe with group values
df.insert(loc=3, column='Group', value='')

for group in range(len(group_subs)):
	df.Group.loc[(df.Animal.isin(group_subs[group]))]= 'Group%i' %(group)

#Add hedonic labels
pal_nums = easygui.multenterbox(
            msg = 'Input how many groups of palatability you want to parse data into..', 
            fields = ['Groups:'], 
            values = ['3'])

#Identify which tastans belong to each palatablity group and label dataframe accordingly
pal_subs = []
for group in range(int(pal_nums[0])):
	group_animals = easygui.multchoicebox(
        msg = 'Which tastants belong in group %i?' %(group+1), 
        choices = ([x for x in sorted(df.SOLUTION.unique())])) 
	pal_subs.append(group_animals)

#Label dataframe with group values
df.insert(loc=4, column='Pal_Group', value='')

for group in range(len(pal_subs)):
	df.Pal_Group.loc[(df.SOLUTION.isin(pal_subs[group]))]= pal_subs[group][0][:1]

#Specify days/conditions to run stats on
group_stat_count = df.loc[~df.Notes.isin(['Hab4','Hab5'])].groupby(['Notes','Condition',\
							   'Group']).count()/df.PRESENTATION.unique()[-1]
group_stat_count =  group_stat_count.Animal.reset_index(level=['Condition', 'Notes'])
group_stat_count.rename(columns={'Animal': 'Animal_count'})

#Test day 1
trimmed_result = df.loc[(df['Notes'] =='Test1') & (df['LICKS'] !=0)]
test1_stats = trimmed_result.anova(dv='LICKS', between=['SOLUTION', 'Group'])
pval = np.round(test1_stats.iloc[2,5],2)

#Plot
plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='SOLUTION', y='LICKS',\
			  hue='Group', hue_order = ['Group0','Group1'],\
			  dodge=True, markers=['o', 's'],order=sorted_solutions,
			  capsize=.1, errwidth=1, palette='dark')

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Fan impact on on Lick Count\n Test Day: One',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.10, 0.9, '$p = %s$' %(pval), ha='center',\
		 va='center', transform=ax.transAxes,\
		 fontsize=16, fontweight='bold')

#Test day 2
trimmed_result = df.loc[(df['Notes'] =='Test2')\
				& (df['Condition'] =='Saline') & (df['LICKS'] !=0)]
test2_stats = trimmed_result.anova(dv='LICKS', between=['SOLUTION', 'Group'])
pval = np.round(test2_stats.iloc[2,5],2)

#Plot
plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='SOLUTION', y='LICKS',\
			  hue='Group', hue_order = ['Group0','Group1'],\
			  dodge=True, markers=['o', 's'],order=sorted_solutions,
			  capsize=.1, errwidth=1, palette='dark')

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Fan impact on on Lick Count\n Test Day: Two',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.10, 0.9, '$p = %s$' %(pval), ha='center',\
		 va='center', transform=ax.transAxes,\
		 fontsize=16, fontweight='bold')

#Test day 3
trimmed_result = df.loc[(df['Notes'] =='Test3')\
				& (df['Condition'] =='Nicotine') & (df['LICKS'] !=0)]
test3_stats = trimmed_result.anova(dv='LICKS', between=['SOLUTION', 'Group'])
pval = np.round(test3_stats.iloc[2,5],2)

#Plot
plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='SOLUTION', y='LICKS',\
			  hue='Group', hue_order = ['Group0','Group1'],\
			  dodge=True, markers=['o', 's'],order=sorted_solutions,
			  capsize=.1, errwidth=1, palette='dark')

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Fan impact on on Lick Count\n Test Day: Three',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.10, 0.9, '$p = %s$' %(pval), ha='center',\
		 va='center', transform=ax.transAxes,\
		 fontsize=16, fontweight='bold')

#PLOT BY GROUP
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Notes'] !='Test1') & \
							(df['Condition'] !='None') &\
							(df['LICKS'] !=0)\
							& (df['Group'] =='Group0')]

#REPEATED MEASURES FOR GROUP0
stats = pg.rm_anova(dv='LICKS',
                  within=['SOLUTION', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

pval0 = np.format_float_scientific(stats.iloc[0,7],1, exp_digits=2)
pval1 = np.format_float_scientific(stats.iloc[1,7],1, exp_digits=2)
pval2 = np.round(stats.iloc[2,7],2)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='SOLUTION', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],order=sorted_solutions,
			  capsize=.1, errwidth=1, palette='dark')

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Lick Count\n Group 0',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.15, 0.9, 'Solution; $p = %s$\n Cond; $p = %s$\n Cond*Solution; $p = %s$' \
			%(pval0,pval1,pval2), ha='center', va='center',\
			transform=ax.transAxes, fontsize=16, fontweight='bold')


#Group1
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Notes'] !='Test1') & \
							(df['Condition'] !='None') &\
							(df['LICKS'] !=0)\
							& (df['Group'] =='Group1')]


#REPEATED MEASURES FOR GROUP1
stats = pg.rm_anova(dv='LICKS',
                  within=['SOLUTION', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

pval0 = np.format_float_scientific(stats.iloc[0,7],1, exp_digits=2)
pval1 = np.format_float_scientific(stats.iloc[1,7],1, exp_digits=2)
pval2 = np.round(stats.iloc[2,7],2)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='SOLUTION', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],order=sorted_solutions,
			  capsize=.1, errwidth=1, palette='dark')

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Lick Count\n Group 1',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.15, 0.9, 'Solution; $p = %s$\n Cond; $p = %s$\n Cond*Solution; $p = %s$' \
			%(pval0,pval1,pval2), ha='center', va='center',\
			transform=ax.transAxes, fontsize=16, fontweight='bold')

#Try Violin Plot
plt.figure(figsize=(12,8))
ax = sns.violinplot(x="SOLUTION", y="LICKS", hue="Condition",\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  data=trimmed_result, palette="muted", split=True,\
			  order= sorted(trimmed_result.SOLUTION.unique()),\
			  scale_hue=True, inner='quartile')

plt.figure(figsize=(12,8))
ax = sns.violinplot(x="SOLUTION", y="Latency", hue="Condition",\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  data=trimmed_result, palette="muted", split=True,\
			  order= sorted(trimmed_result.SOLUTION.unique()),\
			  scale_hue=True, inner='quartile')

plt.figure(figsize=(12,8))
ax = sns.violinplot(x="SOLUTION", y="Lat_First", hue="Condition",\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  data=trimmed_result, palette="muted", split=True,\
			  order= sorted(trimmed_result.SOLUTION.unique()),\
			  scale_hue=True, inner='quartile')

plt.figure(figsize=(12,8))
ax = sns.scatterplot(x="bout_count", y="Bouts_mean", hue="Condition",\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  data=trimmed_result, palette="muted", split=True,\
			  order= sorted(trimmed_result.SOLUTION.unique()),\
			  scale_hue=True, inner='quartile')


kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(plt.scatter, "bout_count", "Bouts_mean", **kws).add_legend())




#ALL
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Notes'] !='Test1') & \
							(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]

#REPEATED MEASURES FOR All
stats = pg.rm_anova(dv='LICKS',
                  within=['SOLUTION', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

pval0 = np.format_float_scientific(stats.iloc[0,7],1, exp_digits=2)
pval1 = np.format_float_scientific(stats.iloc[1,7],1, exp_digits=2)
pval2 = np.round(stats.iloc[2,7],2)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='SOLUTION', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],order=sorted_solutions,
			  capsize=.1, errwidth=1, palette='dark')

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Lick Count\n All',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.15, 0.9, 'Solution; $p = %s$\n Cond; $p = %s$\n Cond*Solution; $p = %s$' \
			%(pval0,pval1,pval2), ha='center', va='center',\
			transform=ax.transAxes, fontsize=16, fontweight='bold')
# =============================================================================
# =============================================================================
# # #REPEATED MEASURES ANOVA
# # #BASED ON HEDONICS
# =============================================================================
# =============================================================================
trimmed_result = df.loc[(df['Notes'] !='Test1')\
						& (df['LICKS'] !=0)\
						&(df['Condition'] !='None')\
						& (df['Group'] =='Group0')\
						& (df['Pal_Group'] !='')]

aov_0 = pg.rm_anova(dv='LICKS',
                  within=['Pal_Group', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='Pal_Group', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],\
			  order=sorted(trimmed_result.Pal_Group.unique()),
			  capsize=.1, errwidth=1, palette='dark')

trimmed_result = df.loc[(df['Notes'] !='Test1')\
						& (df['LICKS'] !=0)\
						&(df['Condition'] !='None')\
						& (df['Group'] =='Group1')\
						& (df['Pal_Group'] !='')]

aov_1 = pg.rm_anova(dv='LICKS',
                  within=['Pal_Group', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='Pal_Group', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],\
			  order=sorted(trimmed_result.Pal_Group.unique()),
			  capsize=.1, errwidth=1, palette='dark')

trimmed_result = df.loc[(df['Notes'] !='Test1')\
						& (df['LICKS'] !=0)\
						&(df['Condition'] !='None')\
						& (df['Pal_Group'] !='')]

aov_all = pg.rm_anova(dv='LICKS',
                  within=['Pal_Group', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='Pal_Group', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],\
			  order=sorted(trimmed_result.Pal_Group.unique()),
			  capsize=.1, errwidth=1, palette='dark')


# =============================================================================
# =============================================================================
# # #REPEATED MEASURES ANOVA
# # #ONLY FOR N and Q
# =============================================================================
# =============================================================================
trimmed_result = df.loc[(df['Notes'] !='Test1')\
						& (df['LICKS'] !=0)\
						&(df['Condition'] !='None')\
						& (df['Group'] =='Group0')\
						& (df.Pal_Group.isin(['N','Q']))]

aov_0 = pg.rm_anova(dv='LICKS',
                  within=['Pal_Group', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='Pal_Group', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],\
			  order=sorted(trimmed_result.Pal_Group.unique()),
			  capsize=.1, errwidth=1, palette='dark')

trimmed_result = df.loc[(df['Notes'] !='Test1')\
						& (df['LICKS'] !=0)\
						&(df['Condition'] !='None')\
						& (df['Group'] =='Group1')\
						& (df.Pal_Group.isin(['N','Q']))]

aov_1 = pg.rm_anova(dv='LICKS',
                  within=['Pal_Group', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='Pal_Group', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],\
			  order=sorted(trimmed_result.Pal_Group.unique()),
			  capsize=.1, errwidth=1, palette='dark')

trimmed_result = df.loc[(df['Notes'] !='Test1')\
						& (df['LICKS'] !=0)\
						&(df['Condition'] !='None')\
						& (df.Pal_Group.isin(['N','Q']))]

aov_all = pg.rm_anova(dv='LICKS',
                  within=['Pal_Group', 'Condition'],
                  subject='Animal', data=trimmed_result,  detailed=True)

plt.figure(figsize=(12,8))
g = sns.pointplot(data=trimmed_result, x='Pal_Group', y='LICKS',\
			  hue='Condition',\
			  hue_order = sorted(trimmed_result.Condition.unique()),\
			  dodge=True, markers=['o', 's'],\
			  order=sorted(trimmed_result.Pal_Group.unique()),
			  capsize=.1, errwidth=1, palette='dark')


#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=20, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks', fontsize=20, fontweight='bold')
    ax.legend(fontsize=16,ncol=2,loc = 'upper right')
    ax.set_title('Lick Count\n All',\
				 fontsize=20, fontweight='bold')
    
	#Set the text be in upper left corner
    ax.text(0.15, 0.9, 'Solution; $p = %s$\n Cond; $p = %s$\n Cond*Solution; $p = %s$' \
			%(pval0,pval1,pval2), ha='center', va='center',\
			transform=ax.transAxes, fontsize=16, fontweight='bold')



#Compare licks across groups by solution for each test day (3WAY-ANOVA)
for day in sorted(df.Notes.loc[~df.Notes.isin(['Hab4','Hab5'])].unique()):
	trimmed_result = df.loc[(df['Notes'] ==day)]
	trimmed_result.anova(dv='LICKS', between=['Condition', 'SOLUTION', 'Group'],
		   ss_type=3)
		
	
	
#Compare licks across groups by solution for each test day (2WAY-ANOVA)
for day in sorted(df.Notes.loc[~df.Notes.isin(['Hab4','Hab5'])].unique()):
	for condition in sorted(df.Condition.unique()):
		trimmed_result = df.loc[(df['Notes'] ==day) & (df['Condition'] ==condition)]
		trimmed_result.anova(dv='LICKS', between=['SOLUTION', 'Group'],
			   ss_type=3)


# =============================================================================
# =============================================================================
# # #PLOT NICITONE IMPACT ON LICKS, GROUPED MEANS
# =============================================================================
# =============================================================================
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Notes'] !='test1') & \
							(df['Condition'] !='None') &\
							(df['LICKS'] !=0)\
							& (df['Group'] =='Group1')]

#Plot grouped bar graphs
g = sns.catplot(x='SOLUTION',\
				y='LICKS',\
				hue='Condition',\
				data=trimmed_result,
				height=6, 
				kind="bar",
				order=sorted_solutions,
				palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Condition.unique())+1),\
				legend=True, legend_out=False,ci=68)
g.fig.set_size_inches(12,8)
legend = g._legend
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=15, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel(ylab.title(), fontsize=15, fontweight='bold')
    ax.set_yticklabels(yticks,fontsize=14)
    ax.legend(fontsize=16,ncol=2)
    ax.set_title('Nicotine Impact on Lick Count',\
				 fontsize=20, fontweight='bold')

# =============================================================================
# =============================================================================
# # #PLOT NICITONE IMPACT ON LICKS, GROUPED MEANS
# =============================================================================
# =============================================================================
#Plot grouped bar graphs
g = sns.catplot(x='SOLUTION',\
				y='Bouts_mean',\
				hue='Condition',\
				data=trimmed_result,
				height=6, 
				kind="bar",
				order=sorted_solutions,
				palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Condition.unique())+1),\
				legend=True, legend_out=False,ci=68)
g.fig.set_size_inches(12,8)
legend = g._legend
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=15, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Licks w/in Bout', fontsize=15, fontweight='bold')
    ax.set_yticklabels(yticks,fontsize=14)
    ax.legend(fontsize=16,ncol=2)
    ax.set_title('Nicotine Impact on Lick w/in a Bout',\
				 fontsize=20, fontweight='bold')

#Plot grouped bar graphs of latency to second lick
g = sns.catplot(x='SOLUTION',\
				y='Lat_First',\
				hue='Condition',\
				data=trimmed_result,
				height=6, 
				kind="bar",
				order=sorted_solutions,
				palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Condition.unique())+1),\
				legend=True, legend_out=False,ci=68)
g.fig.set_size_inches(12,8)
legend = g._legend
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=15, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel('Latency to second lick', fontsize=15, fontweight='bold')
    ax.set_yticklabels(yticks,fontsize=14)
    ax.legend(fontsize=16,ncol=2)
    ax.set_title('Nicotine Impact on Latency to 2nd Lick',\
				 fontsize=20, fontweight='bold')

# =============================================================================
# =============================================================================
# # #PLOT LICKS ACROSS DAYS, GROUPED MEANS
# =============================================================================
# =============================================================================
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]

trimmed_result =trimmed_result.sort_values(by=['Notes'])

#Plot grouped bar graphs
g = sns.catplot(x='SOLUTION',\
				y='LICKS',\
				hue='Notes',\
				data=trimmed_result,
				height=6, 
				kind="bar",
				order=sorted_solutions,
				palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Notes.unique())+1),\
				legend=True, legend_out=False,ci=68)
g.fig.set_size_inches(12,8)
legend = g._legend
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=15, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel(ylab.title(), fontsize=15, fontweight='bold')
    ax.set_yticklabels(yticks,fontsize=14)
    ax.legend(fontsize=16,ncol=3)
    ax.set_title('Nicotine Impact on Lick Count',\
				 fontsize=20, fontweight='bold')


#Plot scatter of licks	
ax = sns.scatterplot(x="Bouts_mean", y="LICKS", hue="Condition", data=trimmed_result)

#Plot grouped bar graphs
g = sns.catplot(x='SOLUTION',\
				y='Bouts_mean',\
				hue='Notes',\
				data=trimmed_result,
				height=6, 
				kind="bar",
				order=sorted_solutions,
				palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Condition.unique())+1),\
				legend=True, legend_out=False,ci=68)
g.fig.set_size_inches(12,8)
legend = g._legend
sns.set_style("whitegrid", {'axes.grid' : False})


# =============================================================================
# #Plot histograms of ILIs by solution
# =============================================================================
#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]

trimmed_result =trimmed_result.sort_values(by=['Notes'])

#Set plotting parameters
kwargs = dict(histtype='stepfilled', alpha=0.6, density=False, bins=40)

#Initiate figure
fig, axs = plt.subplots(nrows=math.ceil(len(trimmed_result.SOLUTION.unique())/3),\
						ncols=math.ceil(len(trimmed_result.SOLUTION.unique())/3),\
						sharex=True, sharey=False,\
						figsize=(10,10))
axes_list = [item for sublist in axs for item in sublist]

for solution in range(len(trimmed_result.SOLUTION.unique())):
	ax = axes_list.pop(0)
	#Set parameters to query dataframe by
	hist_query = trimmed_result.loc[(trimmed_result['SOLUTION']==\
								    sorted_solutions[solution])]
	
	for condition in range(len(hist_query.Condition.unique())):
		
		cond_query = hist_query.loc[(hist_query['Condition']==\
									  hist_query.Condition.unique()[condition])]
		
		#Pad matrix with NaNs
		cond_trials = boolean_indexing([[float(x) for x in y] for y in list(cond_query['ILI_all'])])
		
		#Plot
		ax.hist(cond_trials[(~np.isnan(cond_trials)) &\
				(cond_trials<=1000) & (cond_trials>=15)],\
				 **kwargs)
		
		#Format
		ax.set_xlim(0,400)
		ax.set_title(sorted_solutions[solution])
	
#add legend
fig.legend(hist_query.Condition.unique(),bbox_to_anchor=(0.55, .07),ncol=2)
plt.suptitle('Nicotine impact on ILIs',weight='bold')

#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]
trimmed_result =trimmed_result.sort_values(by=['Notes'])

#Get percentage participated by animal (to include errorbars)
trimmed_result = df.loc[(df['Condition'] !='None')]
percent_check = trimmed_result.groupby(['Animal', 'Notes',\
				'Condition','SOLUTION']).agg({'Lat_First': 'count'}).\
				groupby(level=0).apply(lambda x:100 * x / float(8)).\
				reset_index()

#Plot grouped bar graphs of trials participated in
fig, ax = plt.subplots(figsize=(12,8))
g = sns.barplot(x='SOLUTION',\
				y='Lat_First',\
				hue='Notes',\
				data=percent_check,
				order=sorted_solutions,
				ci='sd',\
				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1))

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})
g.set_ylabel(ylabel="Percent of Trials",fontsize=18, weight='bold')
g.set_xlabel(xlabel='Solution', fontsize=18, weight='bold')
xticks = g.get_xticklabels()
yticks = g.get_yticklabels()
g.set_xticklabels(xticks,fontsize=14)
#ax.set_yticklabels(labels=yticks,fontsize=14)
g.legend(fontsize=16,ncol=3)
g.set_title('Nicotine Impact on Trial Participation',\
				 fontsize=20, weight='bold')


#FAN OFF ANIMALS
trimmed_result = df.loc[(df['Condition'] !='None') &\
				(df.Animal.isin([' AAS7',' AAS8',' AAS9']))]
percent_check = trimmed_result.groupby(['Animal', 'Notes',\
				'Condition','SOLUTION']).agg({'Lat_First': 'count'}).\
				groupby(level=0).apply(lambda x:100 * x / float(8)).\
				reset_index()

#Plot grouped bar graphs of trials participated in
fig, ax = plt.subplots(figsize=(12,8))
g = sns.barplot(x='SOLUTION',\
				y='Lat_First',\
				hue='Notes',\
				data=percent_check,
				order=sorted_solutions,
				ci='sd',\
				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1))

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})
g.set_ylabel(ylabel="Percent of Trials",fontsize=18, weight='bold')
g.set_xlabel(xlabel='Solution', fontsize=18, weight='bold')
xticks = g.get_xticklabels()
yticks = g.get_yticklabels()
g.set_xticklabels(xticks,fontsize=14)
g.legend(fontsize=16,ncol=3)
g.set_title('Nicotine Impact on Trial Participation \n FAN OFF',\
				 fontsize=20, weight='bold')

#FAN ON ANIMALS
trimmed_result = df.loc[(df['Condition'] !='None') &\
				(~df.Animal.isin([' AAS7',' AAS8',' AAS9']))]
percent_check = trimmed_result.groupby(['Animal', 'Notes',\
				'Condition','SOLUTION']).agg({'Lat_First': 'count'}).\
				groupby(level=0).apply(lambda x:100 * x / float(8)).\
				reset_index()

#Plot grouped bar graphs of trials participated in
fig, ax = plt.subplots(figsize=(12,8))
g = sns.barplot(x='SOLUTION',\
				y='Lat_First',\
				hue='Notes',\
				data=percent_check,
				order=sorted_solutions,
				ci='sd',\
				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1))

#Formatting
sns.set_style("whitegrid", {'axes.grid' : False})
g.set_ylabel(ylabel="Percent of Trials",fontsize=18, weight='bold')
g.set_xlabel(xlabel='Solution', fontsize=18, weight='bold')
xticks = g.get_xticklabels()
yticks = g.get_yticklabels()
g.set_xticklabels(xticks,fontsize=14)
#ax.set_yticklabels(labels=yticks,fontsize=14)
g.legend(fontsize=16,ncol=3)
g.set_title('Nicotine Impact on Trial Participation \n FAN ON',\
				 fontsize=20, weight='bold')


#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]

trimmed_result =trimmed_result.sort_values(by=['Notes'])

#Plot grouped bar graphs
g = sns.catplot(x='SOLUTION',\
				y='LICKS',\
				hue='Notes',\
				data=trimmed_result,
				height=6, 
				kind="bar",
				order=sorted_solutions,
				palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Notes.unique())+1),\
				legend=True, legend_out=False,ci='sd')
g.fig.set_size_inches(12,8)
legend = g._legend
sns.set_style("whitegrid", {'axes.grid' : False})

for ax in plt.gcf().axes:
    xlab = ax.get_xlabel()
    ylab = ax.get_ylabel()
    xticks = ax.get_xticklabels()
    yticks = ax.get_yticklabels()
    ax.set_xlabel(xlab.title(), fontsize=15, fontweight='bold')
    ax.set_xticklabels(xticks,fontsize=14)
    ax.set_ylabel(ylab.title(), fontsize=15, fontweight='bold')
    ax.set_yticklabels(yticks,fontsize=14)
    ax.legend(fontsize=16,ncol=3)
    ax.set_title('Nicotine Impact on Lick Count',\
				 fontsize=20, fontweight='bold')



#Unstack all the ILIs across all bouts to perform math
df_lists = df[['Bouts']].unstack().apply(pd.Series)

#Create a new dataframe with calculated columns
Analysis_DF = pd.DataFrame()
Analysis_DF['Animal']=df['Animal']
Analysis_DF['SOLUTION']=df['SOLUTION']
Analysis_DF['Condition']=df['Condition']
Analysis_DF['Trial_num']=df['Trial_num']
Analysis_DF['Notes']=df['Notes']

#Licks across each trial
Analysis_DF['Bout_sum']=np.array(df_lists.sum(axis = 1, skipna = True))

#Plot picks by presentation
trimmed_result = Analysis_DF.loc[(Analysis_DF['Condition'] !='None')]
g=sns.catplot(x="SOLUTION", y="Bout_sum", hue="Trial_num", data=trimmed_result,
                height=6, kind="bar",palette=sns.color_palette("PuBu_r", 10),\
                order=sorted_solutions,ci='sd')
g.fig.set_size_inches(12,8)


#Boxplot +Swarm of licks
trimmed_result = Analysis_DF.loc[(Analysis_DF['Condition'] !='None') &\
								  (Analysis_DF['Notes'] !='test1')]

fig, ax = plt.subplots(figsize=(12,8))
g=sns.boxplot(x="SOLUTION", y="Bout_sum",
            hue="Condition", palette=sns.color_palette\
				("PuBu_r", len(trimmed_result.Notes.unique())+1),
            data=trimmed_result,order=sorted_solutions)


#ANIMAL PLOTS
#Select data
trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0) & (df['Notes'] !='test1')]
# =============================================================================
# g = sns.FacetGrid(trimmed_result, col="Animal",  row="SOLUTION")
# g = g.map(plt.hist, "LICKS", bins=15, color="r")
# 
# =============================================================================

#Licks by presentation order / animal
kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(plt.scatter, "Trial_num", "LICKS", **kws).add_legend())


trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g= g.map(sns.barplot, 'Notes', 'LICKS',order = ['test1','test2','test3'])

#Latency to first Lick by presentation order / animal
kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(plt.scatter, "Trial_num", "Latency", **kws).add_legend())


trimmed_result = df.loc[(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g= g.map(sns.barplot, 'Notes', 'Latency',order = ['test1','test2','test3']).add_legend()


#Licks by presentation order / ALL
kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="SOLUTION",\
				  col_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(plt.scatter, "Trial_num", "LICKS", **kws).add_legend())
t = sns.regplot(x="Trial_num",y="LICKS", \
			   data=trimmed_result, scatter=False)


kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="SOLUTION",\
				  col_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(sns.regplot, "Trial_num", "LICKS", **kws).add_legend())


g = sns.lmplot(x="Trial_num",y="LICKS",hue="Condition",\
			   col="SOLUTION",col_order=sorted_solutions,\
			   data=trimmed_result).add_legend()
axes = g.axes
for i in range(7):
	axes[0,i].set_xlim(0,9)




kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(sns.lmplot, x="Trial_num", y="LICKS", hue="Condition", **kws).add_legend())




#All Licks
g = sns.FacetGrid(trimmed_result, col="SOLUTION",\
				  col_order=sorted_solutions, height=4, aspect=.5)
g = g.map(sns.barplot, "Condition", "LICKS")





#Licks by bout number
kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(plt.scatter, "LICKS", "bout_count", **kws).add_legend())


g = sns.FacetGrid(trimmed_result, col="SOLUTION",\
				  col_order=sorted_solutions, height=4, aspect=.5)
g = g.map(sns.barplot, "Condition", "bout_count")
#bout count by trial
kws = dict(s=50, linewidth=.5, edgecolor="w")
g = sns.FacetGrid(trimmed_result, col="Animal", row="SOLUTION",\
				  row_order=sorted_solutions, hue="Condition", palette="Set1",\
				  hue_order=["Saline", "Nicotine"])
g = (g.map(plt.scatter, "Trial_num", "bout_count", **kws).add_legend())








#NORMALIZE TO WATER
test = df

test['LICKS'] /= test.groupby(['Animal', 'Notes',\
				'Condition','SOLUTION'])['LICKS'].transform(sum)

trimmed_result = test.loc[(test['Condition'] !='None') &\
							(test['LICKS'] !=0) & (test['Notes'] !='test1')]

g = sns.FacetGrid(trimmed_result, col="SOLUTION",\
				  col_order=sorted_solutions, height=4, aspect=.5)
g = g.map(sns.barplot, "Condition", "LICKS")






Analysis_DF.pivot(columns='SOLUTION').ILI_all.plot(kind = 'hist', stacked=True)

pivoted_data = Analysis_DF.pivot(columns='SOLUTION').ILI_all



Analysis_DF['Bouts_calced']=df_lists


df_lists.plot.bar(rot=0, cmap=plt.cm.jet, fontsize=8, width=0.7, figsize=(8,4))


df_lists = dfFull[['ILIs']].unstack().apply(pd.Series)
df_lists = dfFull.columns.unstack().apply(pd.Series)



df_lists.plot.bar(rot=0, cmap=plt.cm.jet, fontsize=8, width=0.7, figsize=(8,4))








# =============================================================================
# 
# #Plot licks per trial by tastant
# #Setting the positions and width for the bars
# pos = list(range(len(df['Trial_num']))) 
# width = 0.25 
# 
# #Group data by tube/presentation
# trial_grouping = df.groupby(['Trial_num','TUBE'])['LICKS'].sum()
# tastants = len(df['SOLUTION'].unique())
# trials = len(df['Trial_num'])
# presentations = int(trials/tastants)
# 
# # Plotting the bars
# fig, ax = plt.subplots(figsize=(12,8))
# 
# # Create grouped bar
# for trial in range(tastants):
# 
#     np.array(pos[trial*presentations:(trial*presentations)+presentations])+0.25
#     plt.bar(np.array(pos[trial*presentations:(trial*presentations)+presentations])\
#             +((trial*presentations)*width), np.array(trial_grouping)[trial:len(pos):tastants])
#     
# mid_points = np.linspace(0,55+((trial*presentations)*0.25),7)    
#     
#  plt.bar(pos[0:56:7],trial_grouping[0:7])
# 
# new = df
# new['SOLUTION'] = new['SOLUTION'].astype('str') 
# new.astype(str)['SOLUTION'].map(lambda x:  type(x))
# 
# ax = out_put_dict['LickDF'].groupby('SOLUTION')['LICKS'].sum().\
# 	sort_values(ascending=False).plot(kind='bar')
# ax.set_ylabel('Licks')
# 
# ax = df.groupby(['Trial_num','TUBE'])['LICKS'].sum().plot(kind='bar')
# 
# test.groupby('TUBE','Trial_num')['LICKS'].sum().\
# 	sort_values(ascending=False).plot(kind='bar')
# 
# 
# 
# new = out_put_dict['LickDF'].sort_values('SOLUTION')
# ax = new.groupby('SOLUTION')['LICKS'].sum().\
# 	plot(kind='bar')
# 
# 
# 
# =============================================================================






