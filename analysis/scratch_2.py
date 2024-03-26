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
data['condition'] = data['condition'].astype('string')

conditions = data['condition'].unique()

sns.boxplot(data=data, x='condition', y='factor', hue='condition')
plt.show()

sns.boxplot(data=data, y='factor')
plt.show()

sns.displot(data, x='factor', hue='condition', kind='kde', fill=True)
plt.show()

# Remove outliers. After visualizing the data in different ways, factor seems to have the biggest outliers
Q1 = data['factor'].quantile(0.25)
Q3 = data['factor'].quantile(0.75)
IQR = Q3 - Q1

upper = Q3 + 1.5 * IQR
lower = Q1 - 1.5 * IQR

upperArray = data.index[data['factor'] >= upper].tolist()
lowerArray = data.index[data['factor'] <= lower].tolist()

data.drop(index=upperArray, inplace=True)
data.drop(index=lowerArray, inplace=True)

sns.boxplot(data=data, x='condition', y='factor', hue='condition')
plt.show()

sns.boxplot(data=data, y='factor')
plt.show()

sns.displot(data, x='factor', hue='condition', kind='kde', fill=True)
plt.show()

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

fig, axes = plt.subplots(1,2, figsize=(14, 12), gridspec_kw={'wspace':0.3, 'hspace':0.1})

## Box plot for each group, regardless of shape
boxprops = {'edgecolor': '#bfbfbf', 'linewidth': 2, 'facecolor':'w'}
lineprops= {'color': '#bfbfbf', 'linewidth': 2}

sns.stripplot(ax=axes[0,0], data=subData, x='speed', y='factor', **stripplot_kwargs)
sns.boxplot(ax=axes[0,0], data=subData, x='speed', y='factor', fliersize=0)

for i, artist in enumerate(axes[0,0].artists):
    artist.set_edgecolor(group_colors[i])
    artist.set_facecolor('None')

plt.show()
data