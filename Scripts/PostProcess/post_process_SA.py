# Post-process the output of GenOpt sensitivity analysis (OutputListingMain.txt)
from typing import DefaultDict
import matplotlib.pyplot as plt
import os
import numpy

# defaultCosts = 2.769268e+02 # baseline
# defaultCosts = 52.425659 # combined
defaultCosts = None

# read the SA params with default values, generated by manipulate_dsin.py
params_def = {}
# initparams_path = r'..\CodeGen\init_params_default_vals.csv'
initparams_path = r'params_for_SA.txt'
if not os.path.exists(initparams_path):
    raise FileNotFoundError('init_params_default_vals.csv not found. Generate that using CodeGen/manipulate_dsin.py')

with open(initparams_path) as file:
    for line in file.readlines():
        if line.startswith('#'):
            continue
        cols = line.split(',')
        params_def[cols[0]] = cols[1]


with open('OutputListingMain.txt') as file:
    lines = file.readlines()



param_names = {}
data_begin = False
sensitivity_list = []
variances = {}

for line in lines:

    # prepare the header
    if not data_begin and line.startswith('Simulation Number'):
        # Simulation Number	Main Iteration	Step Number	f(x)	settings.phi0	settings.height	settings...
        cols = line.rstrip('\n').split('\t')
        for i in range(len(cols)):
            param_names[i] = cols[i]
        data_begin = True
        continue

    if data_begin:
        # find the parameters than are varied
        cols = line.rstrip('\n').split('\t')
        # first 4 cols are runs and f(x) and last one is comment
        for col_num in range(4, len(cols)-1):
            param_name = param_names[col_num]
            param_short_name = param_name[9:] if param_name.startswith('settings.') else param_name
            param_def_val = float(params_def[param_name])
            param_cur_val = float(cols[col_num])
            cost = float(cols[3])
            run = int(cols[0])

            def addToVariances():
                if param_short_name not in variances:
                    variances[param_short_name] = []
                variances[param_short_name].append(cost)
                
            # absolute values to counter negative parameters
            # 1/1000 tolerance of numeric precision
            if param_cur_val > param_def_val + abs(param_def_val)*0.001:
                sa_tup = (param_short_name + '+', cost, param_cur_val, run)
                sensitivity_list.append(sa_tup)
                addToVariances()
                break
                # print(param_name + " is bigger")

            elif param_cur_val < param_def_val - abs(param_def_val)*0.001:
                sa_tup = (param_short_name + '-', cost, param_cur_val, run)
                sensitivity_list.append(sa_tup)
                addToVariances()
                break
                # print(param_name + " is smaller")
            else:
                # this parameter has not been changed
                pass

s_mean = numpy.median([k[1] for k in sensitivity_list])
if defaultCosts is None and 'dummy' in variances:
    defaultCosts = sum(variances['dummy'])/len(variances['dummy'])
elif defaultCosts is None:
    defaultCosts = numpy.min([k[1] for k in sensitivity_list])

def printLine(line:tuple):
    # line = (name, cost, param_cur_val, run)
    printline = '%.6f, %s, %d' % (line[1], line[0], line[3])
    print(printline)
    return printline

with open('sa_output.csv', 'w') as file:
    # sort by costs
    sensitivity_list.sort(key = lambda x: x[1])
    file.write('# Cost, param, run # with mean of %.3f\n' % s_mean)
    lines = '\n'.join(list(map(printLine, sensitivity_list)))
    file.writelines(lines)

with open('sa_runs.csv', 'w') as file:
    # sort by run
    sensitivity_list.sort(key = lambda x: x[3])
    file.write('# run, param, param value, cost %.3f, ratio[%%]\n' % s_mean)
    lines = '\n'.join(list(map(lambda l:'%d, %s, %.3e, %.6f, %.2f' % (l[3], l[0], l[2], l[1], 100*l[1]/defaultCosts), sensitivity_list)))
    file.writelines(lines)

with open('sa_variances.csv', 'w') as file:
    file.write('# param, var\n')
    lines = '\n'.join(list(map(lambda v:'%s, %0.1e' % (v[0], 10*max((abs(v[1][0] - defaultCosts), abs(v[1][1]-defaultCosts)))/defaultCosts), variances.items())))
    file.writelines(lines)
# sort by costs
sensitivity_list.sort(key = lambda x: x[1])
num_to_plot = 50
plotlist = sensitivity_list[:num_to_plot]
plotlist.reverse()
heights = list((x[1] for x in plotlist))
labels = list(('%s (%03d)' % (x[0], x[3]) for x in plotlist))
dpi = 100
plt.figure(figsize = [800/dpi, 800/dpi], dpi=dpi)
plt.rc('ytick', labelsize=6)
plt.axvline(x=s_mean, color='r')

plt.axvline(x=defaultCosts, color='k')
plt.barh(range(len(heights)), heights, tick_label = labels)

plt.subplots_adjust(left=0.4)
plt.xlabel('Total cost')
plt.savefig('sa_result.png')
plt.show()
plt.figure
# print('Sensitivity>', sensitivity_list)
pass

        
