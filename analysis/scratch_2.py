import pandas as pd
import os
import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as stats
import seaborn as sns
import scikit_posthocs as sp

myPath = r'C:/Users/angie/Box/motion_silencing/data/'
figPath = r'C:/Users/angie/Box/motion_silencinf/figs/'

os.chdir(myPath)

data = pd.read_csv('mosiData.csv')

conditions = [
    (data['block'] == 1) | (data['block'] == 4),
    (data['block'] == 3) | (data['block'] == 5),
    data['block'] == 2
]

values = ['Rotation', 'Random', 'Size']

data['condition'] = np.select(conditions, values)
data['condition'] = data['condition'].astype(str)

conditions = data['condition'].unique()

# Remove outliers
Q1 = data[]


subData = data.loc[(data['condition'] == 'Rotation') | (data['condition'] == 'Random')]

sns.set_style('white')
sigColor = '#262626'
sigColorLight = '#bfbfbf'

boxprops = {'edgecolor': '#bfbfbf', 'linewidth': 2, 'facecolor':'w'}
lineprops= {'color': '#bfbfbf', 'linewidth': 2}

pal = {'Rotation':'#DDCC77', 'Random':'#88CCEE'} # yellow is for the regular experiment. Blue is for the one with random motion
strip_pal = ['#bfbfbf']
kwargs = {'palette': pal, 'hue_order': ['Rotation', 'Random']}

boxplot_kwargs = dict({
    'boxprops':boxprops,
    'medianprops':{'color':'k', 'linewidth':2},
    'whiskerprops':lineprops,
    'capprops':lineprops,
    'width':0.75,
    'hue':'condition',
    **kwargs
})

stripplot_kwargs = {
    'size': 5,
    'alpha': 0.7,
    'hue': 'condition',
    'dodge': True,
    'jitter':True,
    'zorder':0,
    **kwargs
}

tick_fontsize = 16
label_fontsize = 20

## Box plot for each group, regardless of shape
boxprops = {'edgecolor': '#bfbfbf', 'linewidth': 2, 'facecolor':'w'}
lineprops= {'color': '#bfbfbf', 'linewidth': 2}

sns.stripplot(data=subData, x='speed', y='factor', hue='condition')
sns.boxplot(data=subData, x='speed', y='factor', hue='condition', fliersize=0)

plt.show()
for i, artist in enumerate(artists):
    artist.set_edgecolor(group_colors[i])
    artist.set_facecolor('None')