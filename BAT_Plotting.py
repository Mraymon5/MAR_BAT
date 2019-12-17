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
# #Read in file
# =============================================================================
#Get name of directory where the data files and hdf5 file sits, and change to that directory for processing
dir_name = easygui.diropenbox()
os.chdir(dir_name)

#Look for the ms8 files in the directory
file_list = os.listdir('./')
file_name = ''
for files in file_list:
    if files[-3:] == 'csv':
        file_name = files

#Read in dataframe from CSV
df = pd.read_csv(file_name)

# =============================================================================
# =============================================================================
# # #PLOT NICITONE IMPACT ON LICKS, GROUPED MEANS
# =============================================================================
# =============================================================================
#Alphabetize the solutions 
sorted_solutions = list(np.sort(np.array(df['SOLUTION'].unique())))

#Set parameters to query dataframe by
trimmed_result = df.loc[(df['Notes'] !='test1') & \
							(df['Condition'] !='None') &\
							(df['LICKS'] !=0)]

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
    ax.set_ylabel(ylab.title(), fontsize=15, fontweight='bold')
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
    ax.set_ylabel(ylab.title(), fontsize=15, fontweight='bold')
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
# p = trimmed_result['ILI_all'].hist(by=trimmed_result['SOLUTION'], bins=2, figsize=(12,10))    
# 
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
# =============================================================================
# 
# #Calculate number of counts an animal could have
# denominator = len(merged_df.Animal.unique())*len(trimmed_result.Trial_num.unique())
# 
# #Plot grouped bar graphs of trials participated in
# fig, ax = plt.subplots(figsize=(12,8))
# g = sns.barplot(x='SOLUTION',\
# 				y='LICKS',\
# 				hue='Notes',\
# 				data=trimmed_result,
# 				estimator=lambda x: len(x) / denominator * 100,\
# 				order=sorted_solutions,\
# 				palette=sns.color_palette("PuBu_r", len(trimmed_result.Notes.unique())+1))
# 
# #Format
# sns.set_style("whitegrid", {'axes.grid' : False})
# g.set_ylabel(ylabel="Percent of Trials",fontsize=18, weight='bold')
# g.set_xlabel(xlabel='Solution', fontsize=18, weight='bold')
# xticks = g.get_xticklabels()
# yticks = g.get_yticklabels()
# g.set_xticklabels(xticks,fontsize=14)
# #ax.set_yticklabels(labels=yticks,fontsize=14)
# g.legend(fontsize=16,ncol=3)
# g.set_title('Nicotine Impact on Trial Participation',\
# 				 fontsize=20, weight='bold')
# =============================================================================

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


#First Latency between first and second lick
g = sns.FacetGrid(trimmed_result, col="SOLUTION",\
				  col_order=sorted_solutions, height=4, aspect=.5)
g = g.map(sns.barplot, "Condition", "Lat_First")


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






