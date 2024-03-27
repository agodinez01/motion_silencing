import pandas as pd
import os
import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as stats
import seaborn as sns
import scikit_posthocs as sp

myPath = r'C:/Users/angie/Box/motion_silencing/data/'
figPath = r'C:/Users/angie/Box/motion_silencing/figs/'

os.chdir(myPath)

data = pd.read_csv('mosiData.csv')

conditions = [
    (data['block'] == 1) | (data['block'] == 4),
    (data['block'] == 3) | (data['block'] == 5),
    data['block'] == 2
]

values = ['Rotation', 'Random', 'Size']

data['condition'] = np.select(conditions, values)
data['condition'] = data['condition'].astype('string')

# Log transform
data['factorLog'] = np.log(data['factor'])

conditions = data['condition'].unique()
runs = ['with', 'without']

# Run the analysis with the lower speed values included and not included
def runAnalysis(data, run):
    # First run it without removing any data
    subData = data.loc[(data['condition'] == 'Rotation') | (data['condition'] == 'Random')]
    myPal = {'Rotation':'#DDCC77', 'Random':'#88CCEE'}
    group_colors = {'Rotation': '#DDCC77', 'Random': '#88CCEE'}

    sns.boxplot(data=subData, x='condition', y='factor', hue='condition', palette=myPal)
    plt.yscale('log')
    plt.show()
    # figname = 'boxplot_raw_data_' + str(run[1]) + '_limits.svg'
    # plt.savefig(fname=figPath + figname, bbox_inches='tight', format='svg', dpi=300)

    # sns.boxplot(data=subData, y='factor')
    # plt.yscale('log')

    sns.displot(subData, x='factor', hue='condition', kind='kde', fill=True, palette=myPal)
    plt.xscale('log')
    plt.show()
    # figname = 'distribution_raw_data_' + str(run[1]) + '_limits.svg'
    # plt.savefig(fname=figPath + figname, bbox_inches='tight', format='svg', dpi=300)

    sns.set_style('white')
    sigColor = '#262626'
    sigColorLight = '#bfbfbf'

    boxprops = {'edgecolor': '#bfbfbf', 'linewidth': 2, 'facecolor': 'w'}
    lineprops = {'color': '#bfbfbf', 'linewidth': 2}

    pal = {'Rotation': '#DDCC77',
           'Random': '#88CCEE'}  # yellow is for the regular experiment. Blue is for the one with random motion

    strip_pal = ['#bfbfbf']
    kwargs = {'palette': pal, 'hue_order': ['Rotation', 'Random']}

    boxplot_kwargs = dict({
        'boxprops': boxprops,
        'medianprops': {'color': 'k', 'linewidth': 2},
        'whiskerprops': lineprops,
        'capprops': lineprops,
        'width': 0.75,
        'hue': 'condition',
        **kwargs
    })

    stripplot_kwargs = {
        'size': 5,
        'alpha': 0.7,
        'hue': 'condition',
        'dodge': True,
        'jitter': True,
        'zorder': 0,
        **kwargs
    }

    tick_fontsize = 16
    label_fontsize = 20

    fig, axes = plt.subplots(1, 1, figsize=(14, 12), gridspec_kw={'wspace': 0.3, 'hspace': 0.1})

    ## Box plot for each group, regardless of shape
    boxprops = {'edgecolor': '#bfbfbf', 'linewidth': 2, 'facecolor': 'w'}
    lineprops = {'color': '#bfbfbf', 'linewidth': 2}

    sns.stripplot(data=subData, x='speed', y='factor', **stripplot_kwargs)
    sns.boxplot(data=subData, x='speed', y='factor', fliersize=0, **boxplot_kwargs)

    axes.axhline(y=1, linestyle='--', color='k')

    for i, artist in enumerate(axes.artists):
        if (i % 2) == 0:
            patchColor = group_colors['Rotation']
        else:
            patchColor = group_colors['Random']
        artist.set_edgecolor(patchColor)
        artist.set_facecolor('None')

    plt.yscale('log')

    plt.setp(axes.get_yticklabels(), fontsize=tick_fontsize)
    plt.setp(axes.get_xticklabels(), fontsize=tick_fontsize)

    # axes.set_ylim(-10, 10)
    axes.set_xlabel('Speed (deg/sec)', fontsize=label_fontsize)
    axes.set_ylabel('Silencing Factor', fontsize=label_fontsize)

    handles, _ = axes.get_legend_handles_labels()
    axes.legend(handles, ['Rotation', 'Random'], loc='best', frameon=False)
    plt.show()

    # figname = 'boxplot_by_speed_raw_data_' + str(run[1]) + '_limits.svg'
    # plt.savefig(fname=figPath + figname, bbox_inches='tight', format='svg', dpi=300)

    # Remove outliers using the log scaled values. After visualizing the data in different ways, factor seems to have the biggest outliers
    Q1 = subData['factorLog'].quantile(0.25)
    Q3 = subData['factorLog'].quantile(0.75)
    IQR = Q3 - Q1

    upper = Q3 + 1.5 * IQR
    lower = Q1 - 1.5 * IQR

    upperArray = subData.index[subData['factorLog'] >= upper].tolist()
    lowerArray = subData.index[subData['factorLog'] <= lower].tolist()

    subData.drop(index=upperArray, inplace=True)
    subData.drop(index=lowerArray, inplace=True)

    subData.to_csv(myPath + 'dataNoOutliers.csv')

    # subData = subdata.loc[(subData['condition'] == 'Rotation') | (subData['condition'] == 'Random')]

    sns.boxplot(data=subData, x='condition', y='factor', hue='condition', palette=myPal)
    plt.yscale('log')
    plt.show()

    # figname = 'boxplot_outliers_removed_' + str(run[1]) + '_limits.svg'
    # plt.savefig(fname=figPath + figname, bbox_inches='tight', format='svg', dpi=300)

    # sns.boxplot(data=subData, y='factor')
    # plt.yscale('log')
    # plt.show()

    sns.displot(subData, x='factor', hue='condition', kind='kde', fill=True, palette=myPal)
    plt.xscale('log')
    plt.show()

    # figname = 'distribution_outliers_removed_' + str(run[1]) + '_limits.svg'
    # plt.savefig(fname=figPath + figname, bbox_inches='tight', format='svg', dpi=300)

    fig, axes = plt.subplots(1, 1, figsize=(14, 12), gridspec_kw={'wspace': 0.3, 'hspace': 0.1})

    sns.stripplot(data=subData, x='speed', y='factor', **stripplot_kwargs)
    sns.boxplot(data=subData, x='speed', y='factor', fliersize=0, **boxplot_kwargs)

    axes.axhline(y=1, linestyle='--', color='k')

    for i, artist in enumerate(axes.artists):
        if (i % 2) == 0:
            patchColor = group_colors['Rotation']
        else:
            patchColor = group_colors['Random']
        artist.set_edgecolor(patchColor)
        artist.set_facecolor('None')

    plt.yscale('log')

    plt.setp(axes.get_yticklabels(), fontsize=tick_fontsize)
    plt.setp(axes.get_xticklabels(), fontsize=tick_fontsize)

    axes.set_ylim(-10, 10)
    axes.set_xlabel('Speed (deg/sec)', fontsize=label_fontsize)
    axes.set_ylabel('Silencing Factor', fontsize=label_fontsize)

    handles, _ = axes.get_legend_handles_labels()
    axes.legend(handles, ['Rotation', 'Random'], loc='best', frameon=False)
    plt.show()

    # figname = 'boxplot_by_speed_outliers_removed_' + str(run[1]) + '_limits.svg'
    # plt.savefig(fname=figPath + figname, bbox_inches='tight', format='svg', dpi=300)

for run in enumerate(runs):
    if run[1] == 'with':
        data = data
        y = 'factor'
        runAnalysis(data, run)
    elif run[1] == 'without':
        data = data.drop(data[(data['speed'] < 3) | (data['speed'] > 130)].index)
        y = 'factor'
        runAnalysis(data, run)
